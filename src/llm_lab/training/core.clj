(ns llm-lab.training.core
  "Core training functionality for LLM experimentation"
  (:require [libpython-clj2.python :as py]
            [libpython-clj2.require :refer [require-python]]
            [clojure.data.json :as json]
            [clojure.java.io :as io]))

(py/initialize!)

;; Import training libraries
(require-python '[torch :as torch]
                '[torch.nn :as nn]
                '[torch.optim :as optim]
                '[transformers :as transformers]
                '[datasets :as datasets]
                '[accelerate :as accelerate])

(defn load-training-config
  "Load training configuration from JSON file"
  [config-path]
  (-> config-path
      slurp
      (json/read-str :key-fn keyword)))

(defn create-model
  "Create a GPT model from configuration"
  [model-config]
  (let [config (py/py. transformers "GPTNeoConfig"
                       :vocab_size (:vocab_size model-config)
                       :max_position_embeddings (:n_positions model-config)
                       :hidden_size (:n_embd model-config)
                       :num_layers (:n_layer model-config)
                       :num_heads (:n_head model-config)
                       :resid_pdrop 0.1
                       :embd_pdrop 0.1
                       :attn_pdrop 0.1)
        model (py/py. transformers "GPTNeoForCausalLM" config)]
    {:config config
     :model model
     :parameter-count (py/py. model "num_parameters")}))

(defn load-dataset
  "Load and prepare training dataset"
  [dataset-name data-dir]
  (let [dataset-path (str data-dir "/processed/" dataset-name)
        tokenizer (py/py. transformers "AutoTokenizer" "from_pretrained" "gpt2")]
    (when (nil? (py/py.- tokenizer "pad_token"))
      (py/py. tokenizer "__setattr__" "pad_token" (py/py.- tokenizer "eos_token")))
    
    ;; Load preprocessed data
    (let [train-data (py/py. datasets "load_from_disk" dataset-path)]
      {:dataset train-data
       :tokenizer tokenizer})))

(defn create-dataloader
  "Create optimized DataLoader for RTX 3080Ti"
  [dataset tokenizer batch-size sequence-length]
  (py/py. torch.utils.data "DataLoader" dataset
          :batch_size batch-size
          :shuffle true
          :num_workers 4
          :pin_memory true
          :drop_last true))

(defn setup-optimizer
  "Setup optimizer with RTX 3080Ti optimizations"
  [model learning-rate]
  (let [optimizer (py/py. optim "AdamW" 
                         (py/py.- model "parameters")
                         :lr learning-rate
                         :betas [0.9 0.95]
                         :eps 1e-8
                         :weight_decay 0.1)]
    optimizer))

(defn setup_mixed_precision
  "Setup automatic mixed precision for memory efficiency"
  []
  (py/py. torch.cuda.amp "GradScaler"))

(defn training-step
  "Single training step with mixed precision"
  [model optimizer scaler dataloader device]
  (py/py. model "train")
  (let [total-loss 0.0
        num-batches 0]
    
    (doseq [batch dataloader]
      (py/py. optimizer "zero_grad")
      
      ;; Move batch to GPU
      (let [input-ids (py/py. batch "to" device)
            labels input-ids]
        
        ;; Forward pass with autocast
        (py/with [autocast (py/py. torch.cuda.amp "autocast")]
          (let [outputs (py/py. model input-ids :labels labels)
                loss (py/py.- outputs "loss")]
            
            ;; Backward pass with gradient scaling
            (py/py. scaler "scale" loss)
            (py/py. scaler "step" optimizer)
            (py/py. scaler "update")
            
            ;; Accumulate loss
            (set! total-loss (+ total-loss (py/py.- loss "item")))
            (set! num-batches (inc num-batches))))))
    
    (/ total-loss num-batches)))

(defn evaluate-model
  "Evaluate model on validation set"
  [model dataloader device]
  (py/py. model "eval")
  (py/with-gil-stack-rc-context
    (py/py. torch "no_grad")
    (let [total-loss 0.0
          num-batches 0]
      
      (doseq [batch dataloader]
        (let [input-ids (py/py. batch "to" device)
              labels input-ids
              outputs (py/py. model input-ids :labels labels)
              loss (py/py.- outputs "loss")]
          
          (set! total-loss (+ total-loss (py/py.- loss "item")))
          (set! num-batches (inc num-batches))))
      
      (/ total-loss num-batches))))

(defn generate-sample
  "Generate text sample during training"
  [model tokenizer prompt max-length device]
  (py/py. model "eval")
  (let [input-ids (py/py. tokenizer "encode" prompt :return_tensors "pt")
        input-ids (py/py. input-ids "to" device)]
    
    (py/with-gil-stack-rc-context
      (py/py. torch "no_grad")
      (let [output-ids (py/py. model "generate" input-ids
                               :max_length max-length
                               :temperature 0.8
                               :do_sample true
                               :pad_token_id (py/py.- tokenizer "eos_token_id"))
            generated-text (py/py. tokenizer "decode" (py/py. output-ids "squeeze")
                                   :skip_special_tokens true)]
        generated-text))))

(defn save-checkpoint
  "Save model checkpoint"
  [model optimizer step config save-dir]
  (let [checkpoint-dir (str save-dir "/checkpoint-" step)]
    (py/py. model "save_pretrained" checkpoint-dir)
    (println (str "✅ Checkpoint saved: " checkpoint-dir))))

(defn train-model
  "Main training loop"
  [config-path]
  (let [config (load-training-config config-path)
        model-config (:model config)
        training-config (:training config)
        opt-config (:optimization config)
        
        device (if (py/py. torch "cuda" "is_available") "cuda:0" "cpu")
        
        ;; Create model
        model-info (create-model model-config)
        model (:model model-info)
        
        ;; Load dataset
        dataset-info (load-dataset (:dataset training-config) "./data")
        dataset (:dataset dataset-info)
        tokenizer (:tokenizer dataset-info)
        
        ;; Create dataloader
        dataloader (create-dataloader dataset tokenizer 
                                    (:batch_size training-config)
                                    1024)
        
        ;; Setup optimizer and mixed precision
        optimizer (setup-optimizer model (:learning_rate training-config))
        scaler (setup_mixed_precision)]
    
    (println "🚀 Starting training...")
    (println (str "Model: " (:name model-config) " (" (:parameter-count model-info) " parameters)"))
    (println (str "Dataset: " (:dataset training-config)))
    (println (str "Device: " device))
    
    ;; Move model to device
    (py/py. model "to" device)
    
    ;; Training loop
    (doseq [step (range 1 (inc (:max_steps training-config)))]
      (let [loss (training-step model optimizer scaler dataloader device)]
        
        (when (= 0 (mod step 100))
          (println (str "Step " step "/" (:max_steps training-config) 
                       " | Loss: " (format "%.4f" loss))))
        
        ;; Generate sample
        (when (= 0 (mod step (:eval_every training-config 500)))
          (let [sample (generate-sample model tokenizer "Once upon a time" 100 device)]
            (println "\n📝 Sample generation:")
            (println sample)
            (println)))
        
        ;; Save checkpoint
        (when (= 0 (mod step (:save_every training-config 1000)))
          (save-checkpoint model optimizer step config "./checkpoints"))))
    
    (println "🎉 Training complete!")
    (save-checkpoint model optimizer "final" config "./checkpoints")))

;; Training monitoring utilities

(defn monitor-gpu-usage
  "Monitor GPU memory and utilization"
  []
  (when (py/py. torch "cuda" "is_available")
    (let [memory-allocated (py/py. torch "cuda" "memory_allocated" 0)
          memory-cached (py/py. torch "cuda" "memory_reserved" 0)
          memory-total 17179869184] ; 16GB in bytes
      {:memory-allocated-gb (/ memory-allocated 1e9)
       :memory-cached-gb (/ memory-cached 1e9)
       :memory-total-gb (/ memory-total 1e9)
       :utilization-percent (* 100 (/ memory-allocated memory-total))})))

(defn training-dashboard
  "Display real-time training statistics"
  [stats]
  (println (str "\n📊 Training Dashboard"))
  (println (str "━━━━━━━━━━━━━━━━━━━━"))
  (println (str "Loss: " (:loss stats)))
  (println (str "Step: " (:step stats) "/" (:total-steps stats)))
  (println (str "Learning Rate: " (:learning-rate stats)))
  (when-let [gpu-stats (monitor-gpu-usage)]
    (println (str "GPU Memory: " (format "%.1f" (:memory-allocated-gb gpu-stats)) 
                 "/" (format "%.1f" (:memory-total-gb gpu-stats)) "GB "
                 "(" (format "%.1f" (:utilization-percent gpu-stats)) "%)"))
    (println)))

(comment
  ;; Training examples
  
  ;; Quick start with TinyStories
  (train-model "./data/quick_start_config.json")
  
  ;; Monitor GPU during training
  (monitor-gpu-usage)
  
  ;; Generate samples
  (def model (create-model {:vocab_size 50257 :n_positions 1024 
                           :n_embd 512 :n_layer 8 :n_head 8}))
  (generate-sample (:model model) tokenizer "The cat" 50 "cuda:0")
)