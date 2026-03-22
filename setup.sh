#!/bin/bash
# LLM Intuition Lab Setup Script
# Optimized for RTX 3080Ti with CUDA support

set -e

echo "🧠 Setting up LLM Intuition Lab..."
echo "Optimizing for RTX 3080Ti with 16GB VRAM"

# Check system requirements
check_requirements() {
    echo "📋 Checking system requirements..."
    
    # Check NVIDIA GPU
    if ! nvidia-smi &> /dev/null; then
        echo "❌ NVIDIA GPU not detected or drivers not installed"
        echo "Please install NVIDIA drivers first"
        exit 1
    fi
    
    # Check CUDA
    if ! nvcc --version &> /dev/null; then
        echo "⚠️  CUDA not found in PATH, will install via conda"
    fi
    
    # Check memory
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$total_ram" -lt 16 ]; then
        echo "⚠️  Less than 16GB RAM detected. Some large models may not fit."
    else
        echo "✅ RAM: ${total_ram}GB"
    fi
    
    # Check GPU details
    gpu_info=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits)
    echo "✅ GPU: $gpu_info"
}

# Install Clojure if needed
install_clojure() {
    if ! clojure --version &> /dev/null; then
        echo "📦 Installing Clojure..."
        curl -O https://download.clojure.org/install/linux-install-1.11.1.1413.sh
        chmod +x linux-install-1.11.1.1413.sh
        sudo ./linux-install-1.11.1.1413.sh
        rm linux-install-1.11.1.1413.sh
        echo "✅ Clojure installed"
    else
        echo "✅ Clojure already installed"
    fi
}

# Setup Python environment with ML libraries
setup_python_env() {
    echo "🐍 Setting up Python environment..."
    
    if ! conda --version &> /dev/null; then
        echo "📦 Installing Miniconda..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
        source $HOME/miniconda3/bin/activate
        conda init bash
        rm Miniconda3-latest-Linux-x86_64.sh
    fi
    
    # Create conda environment for GPU ML
    echo "🔧 Creating conda environment with CUDA support..."
    conda create -n llm-lab python=3.11 -y
    source activate llm-lab
    
    # Install PyTorch with CUDA 12.1 support for RTX 3080Ti
    echo "🔥 Installing PyTorch with CUDA 12.1..."
    conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
    
    # Install ML libraries
    echo "📚 Installing ML libraries..."
    pip install transformers accelerate bitsandbytes
    pip install datasets evaluate rouge_score bleu
    pip install matplotlib seaborn plotly
    pip install scikit-learn scipy numpy pandas
    pip install jupyter notebook jupyterlab
    
    # Install visualization libraries
    pip install altair vega_datasets
    pip install networkx graphviz
    
    # Install libpython-clj dependencies
    pip install numpy scipy matplotlib
    
    echo "✅ Python environment ready"
}

# Setup Clojure dependencies
setup_clojure_deps() {
    echo "⚡ Setting up Clojure dependencies..."
    
    # Create deps.edn
    cat > deps.edn << 'EOF'
{:deps {org.clojure/clojure {:mvn/version "1.12.0"}
        
        ;; Python interop
        clj-python/libpython-clj {:mvn/version "2.025"}
        
        ;; Data manipulation
        techascent/tech.ml.dataset {:mvn/version "7.027"}
        scicloj/tablecloth {:mvn/version "7.027"}
        
        ;; Visualization
        scicloj/clerk {:mvn/version "0.15.957"}
        metasoarous/oz {:mvn/version "2.0.0-alpha5"}
        
        ;; Math and statistics
        generateme/fastmath {:mvn/version "2.4.0"}
        org.apache.commons/commons-math3 {:mvn/version "3.6.1"}
        
        ;; Web interface
        reagent/reagent {:mvn/version "1.2.0"}
        re-frame/re-frame {:mvn/version "1.3.0"}
        
        ;; Utilities
        org.clojure/core.async {:mvn/version "1.6.681"}
        org.clojure/data.json {:mvn/version "2.4.0"}}
 
 :paths ["src" "resources" "notebooks"]
 
 :aliases 
 {:repl {:extra-deps {nrepl/nrepl {:mvn/version "1.0.0"}
                      cider/cider-nrepl {:mvn/version "0.42.1"}}
         :main-opts ["-m" "nrepl.cmdline" "--middleware" 
                     "[cider.nrepl/cider-middleware]"]}
  
  :notebook {:extra-deps {io.github.nextjournal/clerk {:mvn/version "0.15.957"}}
             :exec-fn nextjournal.clerk/serve!
             :exec-args {:browse true :port 7777}}
  
  :dev {:extra-paths ["dev" "test"]
        :extra-deps {org.clojure/tools.namespace {:mvn/version "1.4.5"}}}
  
  :test {:extra-paths ["test"]
         :extra-deps {org.clojure/test.check {:mvn/version "1.1.1"}}}}}
EOF

    # Create directory structure
    mkdir -p src/llm_lab/{core,tokenization,embeddings,attention,transformer,generation,experiments,viz}
    mkdir -p notebooks
    mkdir -p resources/{models,datasets,checkpoints}
    mkdir -p dev test
    
    echo "✅ Clojure project structure created"
}

# Create initial core namespace
create_core_namespace() {
    echo "🏗️  Creating core namespace..."
    
    cat > src/llm_lab/core.clj << 'EOF'
(ns llm-lab.core
  "Core namespace for LLM Intuition Lab"
  (:require [libpython-clj2.python :as py]
            [libpython-clj2.require :refer [require-python]]
            [clojure.java.io :as io]))

(py/initialize!)

;; Import essential Python modules
(require-python '[torch :as torch]
                '[transformers :as transformers]
                '[numpy :as np])

(defn system-info
  "Display system information and readiness"
  []
  {:cuda-available? (py/py. torch "cuda" "is_available")
   :cuda-version (when (py/py. torch "cuda" "is_available")
                   (py/py. torch "version" "cuda"))
   :device-count (py/py. torch "cuda" "device_count")
   :device-name (when (> (py/py. torch "cuda" "device_count") 0)
                  (py/py. torch "cuda" "get_device_name" 0))
   :transformers-version (py/py.- transformers "__version__")
   :torch-version (py/py.- torch "__version__")})

(defn load-model
  "Load a HuggingFace model optimized for RTX 3080Ti"
  [model-name & {:keys [device precision] 
                 :or {device "cuda:0" precision "auto"}}]
  (let [model (py/py. transformers "AutoModel" "from_pretrained" model-name)
        tokenizer (py/py. transformers "AutoTokenizer" "from_pretrained" model-name)]
    (when (py/py. torch "cuda" "is_available")
      (py/py. model "to" device))
    {:model model
     :tokenizer tokenizer
     :device device
     :name model-name}))

(defn quick-test
  "Quick test to verify everything is working"
  []
  (println "🧠 LLM Intuition Lab - Quick Test")
  (println "================================")
  (let [info (system-info)]
    (println "CUDA Available:" (:cuda-available? info))
    (println "CUDA Version:" (:cuda-version info))
    (println "Device Name:" (:device-name info))
    (println "PyTorch Version:" (:torch-version info))
    (println "Transformers Version:" (:transformers-version info)))
  
  (when (py/py. torch "cuda" "is_available")
    (println "\n🚀 Loading test model...")
    (try
      (let [model-info (load-model "gpt2")]
        (println "✅ Model loaded successfully!")
        (println "Model:" (:name model-info))
        (println "Device:" (:device model-info)))
      (catch Exception e
        (println "❌ Error loading model:" (.getMessage e)))))
  
  (println "\n🎉 Setup complete! Ready to explore LLMs."))

;; Run quick test on namespace load
(defonce _init (future (quick-test)))
EOF

    echo "✅ Core namespace created"
}

# Create notebook starter
create_starter_notebook() {
    echo "📓 Creating starter notebook..."
    
    cat > notebooks/getting_started.clj << 'EOF'
^{:nextjournal.clerk/visibility {:code :show}}
(ns notebooks.getting-started
  "Getting Started with LLM Intuition Lab"
  (:require [llm-lab.core :as core]
            [nextjournal.clerk :as clerk]))

;; # Welcome to LLM Intuition Lab! 🧠

;; This interactive notebook will guide you through understanding how Large Language Models work.
;; We'll start with the basics and build up to sophisticated concepts through hands-on exploration.

;; ## System Check

;; First, let's make sure everything is set up correctly:

^{:nextjournal.clerk/visibility {:result :show}}
(core/system-info)

;; ## Your First Model

;; Let's load a small model to start exploring:

^{:nextjournal.clerk/visibility {:result :show}}
(def gpt2-small (core/load-model "gpt2"))

;; ## Next Steps

;; Now you're ready to dive into the learning modules:

;; 1. **Tokenization** - How text becomes numbers
;; 2. **Embeddings** - How words become vectors  
;; 3. **Attention** - How models focus on relevant parts
;; 4. **Transformers** - How the architecture processes information
;; 5. **Generation** - How models create new text

;; Click through the modules in the `notebooks/` directory to continue your journey!
EOF

    echo "✅ Starter notebook created"
}

# Create launch script
create_launch_script() {
    echo "🚀 Creating launch script..."
    
    cat > start-lab.sh << 'EOF'
#!/bin/bash
# Launch LLM Intuition Lab

echo "🧠 Starting LLM Intuition Lab..."

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate llm-lab

# Check if CUDA is available
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"

# Start Clerk notebook server
echo "📓 Starting interactive notebook server..."
echo "Navigate to http://localhost:7777 once started"

clojure -M:notebook -X nextjournal.clerk/serve! :browse true :port 7777
EOF

    chmod +x start-lab.sh
    echo "✅ Launch script created"
}

# Create README with quick start
create_quick_start() {
    echo "📚 Creating quick start guide..."
    
    cat > QUICK_START.md << 'EOF'
# Quick Start Guide

## System Requirements ✅
- RTX 3080Ti (or similar high-end GPU)
- 16GB+ VRAM  
- 32GB+ system RAM
- Ubuntu/Linux with NVIDIA drivers

## Launch the Lab 🚀

```bash
# Start the interactive environment
./start-lab.sh
```

This will:
1. Activate the conda environment
2. Verify CUDA availability  
3. Start the Clerk notebook server at http://localhost:7777

## Your First Exploration 🔍

1. Open http://localhost:7777 in your browser
2. Navigate to `notebooks/getting_started.clj`
3. Follow the guided tour through LLM concepts

## Learning Path 📚

1. **Tokenization** (`notebooks/01_tokenization.clj`)
   - How text becomes numbers
   - Different tokenization strategies
   - Interactive tokenization playground

2. **Embeddings** (`notebooks/02_embeddings.clj`) 
   - Words as high-dimensional vectors
   - Semantic relationships in vector space
   - Interactive embedding exploration

3. **Attention** (`notebooks/03_attention.clj`)
   - How models focus on relevant information
   - Attention pattern visualization
   - Multi-head attention analysis

4. **Transformers** (`notebooks/04_transformer.clj`)
   - Complete architecture understanding
   - Layer-by-layer analysis
   - Information flow visualization

5. **Generation** (`notebooks/05_generation.clj`)
   - How models create text
   - Different sampling strategies
   - Interactive generation playground

## Troubleshooting 🔧

### CUDA Issues
```bash
# Check CUDA availability
python -c "import torch; print(torch.cuda.is_available())"
nvidia-smi
```

### Memory Issues  
- Start with smaller models (gpt2, distilgpt2)
- Use FP16 precision for larger models
- Monitor GPU memory with `nvidia-smi`

### Performance Tips
- Use batch size 1-4 for exploration
- Enable gradient checkpointing for large models
- Consider model quantization for memory efficiency

## Need Help? 🆘
- Check the `notebooks/` directory for guided tutorials
- See `IMPLEMENTATION_PLAN.md` for technical details
- GPU-specific optimizations in `src/llm_lab/gpu.clj`
EOF

    echo "✅ Quick start guide created"
}

# Main setup flow
main() {
    echo "🎯 Starting LLM Intuition Lab setup for RTX 3080Ti..."
    
    check_requirements
    install_clojure
    setup_python_env
    setup_clojure_deps
    create_core_namespace
    create_starter_notebook
    create_launch_script
    create_quick_start
    
    echo ""
    echo "🎉 Setup complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 To start exploring: ./start-lab.sh"
    echo "📖 Quick start guide: QUICK_START.md"
    echo "🌐 Notebook server will open at http://localhost:7777"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"
EOF