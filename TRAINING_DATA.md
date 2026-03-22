# Training Data Preparation System
**Open datasets ready for RTX 3080Ti experimentation**

## Available Datasets

### Text Generation Training
- **TinyStories** (2GB) - Simple stories for quick model training
- **OpenWebText** (38GB) - Open recreation of GPT-2 training data  
- **BookCorpus** (5GB) - Public domain books
- **WikiText-103** (500MB) - Wikipedia articles
- **C4** (Common Crawl, 750GB) - Large-scale web text

### Specialized Domains
- **CodeParrot** (50GB) - Code repositories for code generation models
- **PubMed** (30GB) - Scientific papers for domain-specific models
- **ArXiv** (15GB) - Academic papers with LaTeX
- **StackOverflow** (10GB) - Q&A for instruction following

### Multilingual Options
- **mC4** (9TB total, language-specific subsets) - Multilingual Common Crawl
- **CC100** (2.5TB) - 100+ languages from Common Crawl
- **OPUS** (Various sizes) - Parallel text for translation

## RTX 3080Ti Optimized Datasets

### Quick Start (< 2GB)
Perfect for rapid experimentation and learning:
```clojure
{:tinystories {:size "2GB"
               :tokens "~500M" 
               :description "Simple children's stories"
               :training-time "~6 hours"}
 
 :wikitext-103 {:size "500MB"
                :tokens "~100M"
                :description "Wikipedia articles"
                :training-time "~2 hours"}}
```

### Medium Scale (2-20GB)  
For serious experimentation:
```clojure
{:bookCorpus {:size "5GB"
              :tokens "~1.2B"
              :description "Public domain literature"
              :training-time "~24 hours"}
              
 :arxiv {:size "15GB"
         :tokens "~3.5B"
         :description "Academic papers with LaTeX"
         :training-time "~3 days"}}
```

### Large Scale (20GB+)
For advanced users with patience:
```clojure
{:openwebtext {:size "38GB"
               :tokens "~8.5B"
               :description "GPT-2 style web text"
               :training-time "~1 week"}
               
 :codeparrot {:size "50GB"
              :tokens "~12B" 
              :description "Code repositories"
              :training-time "~10 days"}}
```

## Data Preparation Pipeline

### 1. Download Management
```bash
# Download specific datasets
./data/download.sh --dataset tinystories --verify-checksums
./data/download.sh --dataset openwebtext --resume-partial

# Bulk download for offline work
./data/download.sh --preset rtx-3080ti-friendly
```

### 2. Preprocessing Pipeline  
```clojure
(ns llm-lab.data.preprocessing
  (:require [llm-lab.tokenization :as tokenize]))

(defn prepare-training-data
  "Convert raw text to tokenized training format"
  [dataset-name & {:keys [tokenizer sequence-length batch-size]
                   :or {tokenizer :gpt2
                        sequence-length 1024
                        batch-size 8}}]
  (-> (load-raw-dataset dataset-name)
      (tokenize-dataset tokenizer)
      (chunk-sequences sequence-length)
      (batch-data batch-size)
      (save-preprocessed)))
```

### 3. Memory-Efficient Loading
```clojure
(defn streaming-dataloader
  "Memory-efficient dataloader for RTX 3080Ti"
  [dataset batch-size]
  {:pre-computed-batches true
   :memory-mapping true
   :background-loading true
   :gpu-transfer-optimization true})
```

## Interactive Data Exploration

### Data Statistics Dashboard
```clojure
(defn dataset-dashboard [dataset-name]
  (viz/dashboard
    {:dataset-stats (analyze-dataset dataset-name)
     :token-distribution (plot-token-frequencies dataset-name)
     :vocabulary-coverage (analyze-vocabulary dataset-name)
     :training-estimates (estimate-training-time dataset-name :rtx-3080ti)}))
```

### Tokenization Analysis
```clojure
(defn tokenization-analysis [dataset-name tokenizer]
  (let [sample-texts (sample-dataset dataset-name 1000)
        token-stats (analyze-tokenization sample-texts tokenizer)]
    (viz/tokenization-report token-stats)))
```

## Training-Ready Configurations

### Nano Models (For Learning)
```clojure
{:tinygpt {:parameters "1M"
           :layers 2
           :heads 2
           :dataset :tinystories
           :training-time "30 minutes"}
           
 :microgpt {:parameters "10M"
            :layers 4
            :heads 4
            :dataset :wikitext-103
            :training-time "3 hours"}}
```

### Small Models (For Experimentation)  
```clojure
{:smallgpt {:parameters "100M"
            :layers 8
            :heads 8
            :dataset :bookCorpus
            :training-time "24 hours"}
            
 :codegpt-small {:parameters "150M"
                 :layers 10
                 :heads 10
                 :dataset :codeparrot-subset
                 :training-time "36 hours"}}
```

### Model Architecture Templates
```clojure
(defn create-training-config
  [model-size dataset-name]
  (let [optimal-config (calculate-optimal-config model-size :rtx-3080ti)]
    {:architecture optimal-config
     :dataset (prepare-dataset dataset-name optimal-config)
     :training {:batch-size (:batch-size optimal-config)
               :learning-rate (:learning-rate optimal-config)
               :gradient-accumulation (:grad-accum optimal-config)}
     :checkpointing {:save-every "1000 steps"
                    :keep-best 3
                    :resume-capability true}}))
```

## Dataset Quality Tools

### Content Analysis
```clojure
(defn analyze-dataset-quality [dataset-name]
  {:language-detection (detect-languages dataset-name)
   :content-categories (categorize-content dataset-name)  
   :quality-metrics {:duplicates (find-duplicates dataset-name)
                    :toxicity (analyze-toxicity dataset-name)
                    :privacy (scan-pii dataset-name)}
   :recommendations (generate-filtering-recommendations dataset-name)})
```

### Data Filtering Pipeline
```clojure
(defn filter-dataset
  [dataset-name filters]
  (-> (load-dataset dataset-name)
      (apply-language-filter (:languages filters))
      (apply-quality-filter (:min-quality filters))
      (apply-length-filter (:min-length filters) (:max-length filters))
      (apply-content-filter (:exclude-categories filters))
      (save-filtered-dataset)))
```

## Training Monitoring

### Live Training Dashboard
```clojure
(defn training-dashboard [model training-run]
  (viz/live-dashboard
    {:loss-curves (plot-training-loss training-run)
     :gpu-utilization (monitor-gpu-usage)
     :memory-usage (track-memory-usage)
     :generation-samples (sample-generations model)
     :convergence-metrics (analyze-convergence training-run)}))
```

### Experiment Tracking
```clojure
(defn track-experiment [experiment-config]
  {:experiment-id (generate-experiment-id)
   :config experiment-config
   :metrics (track-training-metrics)
   :checkpoints (manage-checkpoints)
   :reproducibility {:random-seed (get-seed)
                    :environment (capture-environment)
                    :git-commit (get-git-commit)}})
```

## Hardware Optimization

### RTX 3080Ti Memory Management
```clojure
(defn optimize-for-rtx-3080ti [training-config]
  (let [vram-gb 16
        optimal-batch-size (calculate-max-batch-size vram-gb (:model-size training-config))]
    (assoc training-config
      :batch-size optimal-batch-size
      :gradient-checkpointing true
      :mixed-precision true
      :dataloader-workers 4
      :pin-memory true)))
```

### Training Efficiency
```clojure
(defn efficient-training-setup [model-config]
  {:model (load-model-with-optimizations model-config)
   :optimizer (create-memory-efficient-optimizer model-config)
   :scheduler (create-adaptive-scheduler model-config)
   :dataloader (create-optimized-dataloader model-config)
   :checkpointing (setup-efficient-checkpointing model-config)})
```

## Getting Started with Training Data

### Quick Setup
```bash
# Download and prepare TinyStories for immediate experimentation
./scripts/quick-start-training.sh

# This will:
# 1. Download TinyStories (2GB)
# 2. Preprocess and tokenize
# 3. Set up training configuration
# 4. Run a small model training demo
```

### Interactive Data Selection
```clojure
;; Launch data selection wizard
(data-selection-wizard
  {:hardware :rtx-3080ti
   :experience-level :intermediate
   :research-interest :generation
   :time-budget "1 week"})

;; Returns personalized dataset recommendations
;; with estimated training times and memory requirements
```

This comprehensive data preparation system gives you everything needed to train your own models on your RTX 3080Ti, from tiny experimental models to serious research-scale training.