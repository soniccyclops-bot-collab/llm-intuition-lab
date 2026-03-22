#!/bin/bash
# Training Data Download and Preparation Script
# Optimized for RTX 3080Ti experimentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
CACHE_DIR="$DATA_DIR/cache"
PROCESSED_DIR="$DATA_DIR/processed"

# Create directory structure
mkdir -p "$DATA_DIR"/{raw,processed,cache}

echo "📊 LLM Training Data Preparation"
echo "================================"
echo "Optimized for RTX 3080Ti (16GB VRAM)"

# Dataset configurations
declare -A DATASETS=(
    # Quick start datasets (< 2GB)
    ["tinystories"]="roneneldan/TinyStories 2GB 500M 6h"
    ["wikitext103"]="wikitext-103-raw-v1 500MB 100M 2h"
    ["imdb"]="imdb-reviews 80MB 25M 30m"
    
    # Medium scale datasets (2-20GB)  
    ["bookcorpus"]="bookcorpus 5GB 1.2B 24h"
    ["openwebtext"]="openwebtext 38GB 8.5B 1w"
    ["arxiv"]="arxiv-dataset 15GB 3.5B 3d"
    
    # Code datasets
    ["codeparrot-small"]="codeparrot-clean-subset 10GB 2.5B 2d"
    ["the-stack-python"]="the-stack-python-subset 8GB 2B 36h"
    
    # Specialized datasets
    ["pubmed"]="pubmed-abstracts 5GB 1.3B 24h"
    ["stackexchange"]="stackexchange-paired 3GB 800M 12h"
)

show_datasets() {
    echo "📋 Available Datasets:"
    echo "====================="
    echo
    printf "%-20s %-8s %-8s %-8s %s\n" "Dataset" "Size" "Tokens" "Train" "Description"
    echo "--------------------------------------------------------------------------------"
    
    for dataset in "${!DATASETS[@]}"; do
        IFS=' ' read -r name size tokens time desc <<< "${DATASETS[$dataset]}"
        printf "%-20s %-8s %-8s %-8s %s\n" "$dataset" "$size" "$tokens" "$time" "$desc"
    done
    echo
}

download_dataset() {
    local dataset_name="$1"
    local force_download="$2"
    
    if [[ ! -n "${DATASETS[$dataset_name]}" ]]; then
        echo "❌ Unknown dataset: $dataset_name"
        show_datasets
        exit 1
    fi
    
    IFS=' ' read -r hf_name size tokens time desc <<< "${DATASETS[$dataset_name]}"
    
    echo "📥 Downloading $dataset_name..."
    echo "   Size: $size | Tokens: $tokens | Est. training time: $time"
    
    local dataset_dir="$DATA_DIR/raw/$dataset_name"
    
    if [[ -d "$dataset_dir" && "$force_download" != "true" ]]; then
        echo "✅ Dataset already exists. Use --force to re-download."
        return 0
    fi
    
    case "$dataset_name" in
        "tinystories")
            download_tinystories "$dataset_dir"
            ;;
        "wikitext103")
            download_wikitext103 "$dataset_dir"
            ;;
        "imdb")
            download_imdb "$dataset_dir"
            ;;
        "bookcorpus")
            download_bookcorpus "$dataset_dir"
            ;;
        "openwebtext")
            download_openwebtext "$dataset_dir"
            ;;
        *)
            download_huggingface_dataset "$hf_name" "$dataset_dir"
            ;;
    esac
    
    echo "✅ Downloaded $dataset_name to $dataset_dir"
}

download_tinystories() {
    local output_dir="$1"
    mkdir -p "$output_dir"
    
    echo "   Downloading TinyStories from HuggingFace..."
    python3 -c "
from datasets import load_dataset
import os

dataset = load_dataset('roneneldan/TinyStories', split='train')
output_dir = '$output_dir'
os.makedirs(output_dir, exist_ok=True)

# Save as text files for easy processing
with open(f'{output_dir}/train.txt', 'w') as f:
    for i, example in enumerate(dataset):
        f.write(example['text'] + '\n\n')
        if i % 10000 == 0:
            print(f'Processed {i} stories...')

print(f'Saved {len(dataset)} stories to {output_dir}/train.txt')
"
}

download_wikitext103() {
    local output_dir="$1"
    mkdir -p "$output_dir"
    
    echo "   Downloading WikiText-103..."
    python3 -c "
from datasets import load_dataset
import os

dataset = load_dataset('wikitext', 'wikitext-103-raw-v1')
output_dir = '$output_dir'
os.makedirs(output_dir, exist_ok=True)

for split in ['train', 'validation', 'test']:
    with open(f'{output_dir}/{split}.txt', 'w') as f:
        for example in dataset[split]:
            if example['text'].strip():  # Skip empty lines
                f.write(example['text'] + '\n')
    print(f'Saved {split} split to {output_dir}')
"
}

download_imdb() {
    local output_dir="$1"
    mkdir -p "$output_dir"
    
    echo "   Downloading IMDB Reviews..."
    python3 -c "
from datasets import load_dataset
import os

dataset = load_dataset('imdb')
output_dir = '$output_dir'
os.makedirs(output_dir, exist_ok=True)

for split in ['train', 'test']:
    with open(f'{output_dir}/{split}.txt', 'w') as f:
        for example in dataset[split]:
            # Format: [POSITIVE/NEGATIVE] review text
            label = 'POSITIVE' if example['label'] == 1 else 'NEGATIVE'
            f.write(f'[{label}] {example[\"text\"]}\n\n')
    print(f'Saved {split} split to {output_dir}')
"
}

download_bookcorpus() {
    local output_dir="$1"
    mkdir -p "$output_dir"
    
    echo "   Downloading BookCorpus (this may take a while)..."
    echo "   Note: BookCorpus requires special access. Using public domain books instead."
    
    # Download Project Gutenberg books as alternative
    python3 -c "
import requests
import os
from pathlib import Path

output_dir = Path('$output_dir')
output_dir.mkdir(exist_ok=True)

# List of public domain book IDs from Project Gutenberg
book_ids = [
    74, 2701, 1342, 84, 174, 11, 1661, 76, 244, 5200,
    135, 345, 2600, 1400, 100, 205, 408, 514, 1184, 1322
]

books_text = []
for book_id in book_ids:
    try:
        url = f'https://www.gutenberg.org/files/{book_id}/{book_id}-0.txt'
        response = requests.get(url, timeout=30)
        if response.status_code == 200:
            books_text.append(response.text)
            print(f'Downloaded book {book_id}')
        else:
            print(f'Failed to download book {book_id}')
    except Exception as e:
        print(f'Error downloading book {book_id}: {e}')

# Combine all books
with open(output_dir / 'books.txt', 'w', encoding='utf-8') as f:
    for book in books_text:
        f.write(book + '\n\n' + '='*50 + '\n\n')

print(f'Saved {len(books_text)} books to {output_dir}/books.txt')
"
}

download_openwebtext() {
    local output_dir="$1"
    mkdir -p "$output_dir"
    
    echo "   Downloading OpenWebText (this will take several hours)..."
    echo "   Note: This is a large dataset. Consider starting with a subset."
    
    python3 -c "
from datasets import load_dataset
import os

try:
    # Try to download a subset first
    dataset = load_dataset('openwebtext', streaming=True)
    output_dir = '$output_dir'
    os.makedirs(output_dir, exist_ok=True)
    
    count = 0
    with open(f'{output_dir}/openwebtext_subset.txt', 'w') as f:
        for example in dataset['train'].take(100000):  # Take first 100k examples
            f.write(example['text'] + '\n\n')
            count += 1
            if count % 1000 == 0:
                print(f'Processed {count} documents...')
    
    print(f'Saved {count} documents to subset file')
    
except Exception as e:
    print(f'Error downloading OpenWebText: {e}')
    print('Consider downloading manually or using a smaller dataset first')
"
}

download_huggingface_dataset() {
    local dataset_name="$1"
    local output_dir="$2"
    
    echo "   Downloading $dataset_name from HuggingFace..."
    python3 -c "
from datasets import load_dataset
import os
import json

try:
    dataset = load_dataset('$dataset_name')
    output_dir = '$output_dir'
    os.makedirs(output_dir, exist_ok=True)
    
    # Save dataset info
    with open(f'{output_dir}/dataset_info.json', 'w') as f:
        json.dump({
            'name': '$dataset_name',
            'splits': list(dataset.keys()),
            'features': str(dataset['train'].features) if 'train' in dataset else 'Unknown'
        }, f, indent=2)
    
    # Save each split
    for split_name, split_data in dataset.items():
        with open(f'{output_dir}/{split_name}.txt', 'w') as f:
            for example in split_data:
                # Try to extract text field
                text = ''
                if 'text' in example:
                    text = example['text']
                elif 'content' in example:
                    text = example['content']
                elif 'article' in example:
                    text = example['article']
                else:
                    # Convert to string representation
                    text = str(example)
                
                if text.strip():
                    f.write(text + '\n\n')
        
        print(f'Saved {split_name} split')
    
    print(f'Successfully downloaded {dataset_name}')
    
except Exception as e:
    print(f'Error downloading {dataset_name}: {e}')
"
}

preprocess_dataset() {
    local dataset_name="$1"
    local tokenizer="${2:-gpt2}"
    
    echo "🔧 Preprocessing $dataset_name with $tokenizer tokenizer..."
    
    local input_dir="$DATA_DIR/raw/$dataset_name"
    local output_dir="$PROCESSED_DIR/$dataset_name"
    
    mkdir -p "$output_dir"
    
    python3 -c "
import os
from pathlib import Path
from transformers import AutoTokenizer
import json

input_dir = Path('$input_dir')
output_dir = Path('$output_dir')
tokenizer_name = '$tokenizer'

# Load tokenizer
tokenizer = AutoTokenizer.from_pretrained(tokenizer_name)
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

print(f'Using tokenizer: {tokenizer_name}')
print(f'Vocabulary size: {len(tokenizer)}')

# Process all text files in input directory
total_tokens = 0
total_examples = 0

for text_file in input_dir.glob('*.txt'):
    print(f'Processing {text_file.name}...')
    
    with open(text_file, 'r', encoding='utf-8') as f:
        text = f.read()
    
    # Tokenize
    tokens = tokenizer.encode(text)
    total_tokens += len(tokens)
    total_examples += 1
    
    # Save tokenized version
    output_file = output_dir / f'{text_file.stem}_tokenized.json'
    with open(output_file, 'w') as f:
        json.dump({
            'tokens': tokens,
            'token_count': len(tokens),
            'source_file': text_file.name
        }, f)
    
    print(f'  Tokenized: {len(tokens):,} tokens')

# Save preprocessing summary
summary = {
    'dataset': '$dataset_name',
    'tokenizer': tokenizer_name,
    'vocab_size': len(tokenizer),
    'total_tokens': total_tokens,
    'total_files': total_examples,
    'avg_tokens_per_file': total_tokens // max(total_examples, 1)
}

with open(output_dir / 'preprocessing_summary.json', 'w') as f:
    json.dump(summary, f, indent=2)

print(f'\\n✅ Preprocessing complete:')
print(f'   Total tokens: {total_tokens:,}')
print(f'   Files processed: {total_examples}')
print(f'   Saved to: {output_dir}')
"
}

estimate_training_time() {
    local dataset_name="$1"
    local model_size="${2:-125M}"
    
    if [[ ! -n "${DATASETS[$dataset_name]}" ]]; then
        echo "❌ Unknown dataset: $dataset_name"
        return 1
    fi
    
    IFS=' ' read -r name size tokens time desc <<< "${DATASETS[$dataset_name]}"
    
    echo "⏱️  Training Time Estimation for $dataset_name"
    echo "=============================================="
    echo "Dataset: $desc"
    echo "Size: $size"
    echo "Tokens: $tokens"
    echo "Model Size: $model_size"
    echo "Hardware: RTX 3080Ti (16GB VRAM)"
    echo
    echo "Estimated Training Times:"
    echo "  Quick experiment (1 epoch):  $(echo $time | sed 's/[0-9]*h/&\/10/g' | sed 's/[0-9]*d/&\/10/g' | sed 's/[0-9]*w/&\/10/g')"
    echo "  Full training (3 epochs):    $time"
    echo "  Convergence (10+ epochs):    $(echo $time | sed 's/h/ hours x 3 ≈/g' | sed 's/d/ days x 3 ≈/g' | sed 's/w/ weeks x 3 ≈/g')"
    echo
    echo "💡 Tips for RTX 3080Ti:"
    echo "  - Use mixed precision (FP16) to double effective memory"
    echo "  - Enable gradient checkpointing for larger models" 
    echo "  - Start with smaller models (125M) before scaling up"
    echo "  - Monitor GPU temperature and power limits"
}

quick_start() {
    echo "🚀 Quick Start: Setting up TinyStories for immediate experimentation"
    echo "=================================================================="
    
    # Download TinyStories
    download_dataset "tinystories"
    
    # Preprocess with GPT-2 tokenizer
    preprocess_dataset "tinystories" "gpt2"
    
    # Create training configuration
    cat > "$DATA_DIR/quick_start_config.json" << 'EOF'
{
  "model": {
    "name": "tiny-gpt",
    "vocab_size": 50257,
    "n_positions": 1024,
    "n_ctx": 1024,
    "n_embd": 512,
    "n_layer": 8,
    "n_head": 8
  },
  "training": {
    "dataset": "tinystories",
    "batch_size": 8,
    "learning_rate": 3e-4,
    "max_steps": 10000,
    "warmup_steps": 1000,
    "save_every": 1000,
    "eval_every": 500
  },
  "optimization": {
    "mixed_precision": true,
    "gradient_checkpointing": false,
    "dataloader_workers": 4
  }
}
EOF
    
    echo "✅ Quick start setup complete!"
    echo "   Dataset: TinyStories (2GB, ~500M tokens)"
    echo "   Model: 8-layer GPT (50M parameters)"
    echo "   Training time: ~6 hours"
    echo "   Config saved to: $DATA_DIR/quick_start_config.json"
    echo
    echo "🎯 Next steps:"
    echo "   1. Review the training configuration"
    echo "   2. Start training with: clojure -M:train --config quick_start_config.json"
    echo "   3. Monitor progress at: http://localhost:6006 (TensorBoard)"
}

rtx_3080ti_preset() {
    echo "🎯 RTX 3080Ti Preset: Downloading curated datasets for GPU experimentation"
    echo "======================================================================="
    
    echo "📥 Downloading small datasets for learning..."
    download_dataset "tinystories"
    download_dataset "imdb"
    download_dataset "wikitext103"
    
    echo "🔧 Preprocessing datasets..."
    preprocess_dataset "tinystories" "gpt2"
    preprocess_dataset "imdb" "gpt2"
    preprocess_dataset "wikitext103" "gpt2"
    
    echo "📊 Creating training configurations..."
    
    # Create different model size configs
    for model_size in "1M" "10M" "50M" "125M"; do
        case $model_size in
            "1M")   layers=2; heads=2; embd=128 ;;
            "10M")  layers=4; heads=4; embd=256 ;;
            "50M")  layers=6; heads=6; embd=384 ;;
            "125M") layers=8; heads=8; embd=512 ;;
        esac
        
        cat > "$DATA_DIR/rtx_3080ti_${model_size}.json" << EOF
{
  "model": {
    "name": "gpt-${model_size}",
    "vocab_size": 50257,
    "n_positions": 1024,
    "n_ctx": 1024,
    "n_embd": ${embd},
    "n_layer": ${layers},
    "n_head": ${heads}
  },
  "training": {
    "batch_size": $(( 32 / layers )),
    "learning_rate": 3e-4,
    "max_steps": 20000,
    "warmup_steps": 2000,
    "gradient_accumulation_steps": $(( layers > 6 ? 2 : 1 ))
  },
  "optimization": {
    "mixed_precision": true,
    "gradient_checkpointing": $(( layers > 6 ? "true" : "false" )),
    "compile_model": true
  }
}
EOF
    done
    
    echo "✅ RTX 3080Ti preset complete!"
    echo "   Downloaded: TinyStories, IMDB, WikiText-103"
    echo "   Preprocessed: All datasets tokenized with GPT-2"
    echo "   Configurations: 1M, 10M, 50M, 125M parameter models"
    echo "   Total size: ~3GB"
}

# Parse command line arguments
case "${1:-help}" in
    "list"|"ls")
        show_datasets
        ;;
    "download")
        if [[ -z "$2" ]]; then
            echo "❌ Usage: $0 download <dataset_name> [--force]"
            show_datasets
            exit 1
        fi
        force=""
        if [[ "$3" == "--force" ]]; then
            force="true"
        fi
        download_dataset "$2" "$force"
        ;;
    "preprocess")
        if [[ -z "$2" ]]; then
            echo "❌ Usage: $0 preprocess <dataset_name> [tokenizer]"
            exit 1
        fi
        preprocess_dataset "$2" "${3:-gpt2}"
        ;;
    "estimate")
        if [[ -z "$2" ]]; then
            echo "❌ Usage: $0 estimate <dataset_name> [model_size]"
            exit 1
        fi
        estimate_training_time "$2" "${3:-125M}"
        ;;
    "quick-start")
        quick_start
        ;;
    "rtx-preset")
        rtx_3080ti_preset
        ;;
    "help"|"-h"|"--help")
        echo "📚 LLM Training Data Manager"
        echo "=========================="
        echo
        echo "Commands:"
        echo "  list                     Show available datasets"
        echo "  download <name> [--force] Download dataset"
        echo "  preprocess <name> [tok]  Preprocess with tokenizer"
        echo "  estimate <name> [size]   Estimate training time"
        echo "  quick-start             Setup TinyStories for immediate use"
        echo "  rtx-preset              Download RTX 3080Ti optimized datasets"
        echo
        echo "Examples:"
        echo "  $0 quick-start                    # Ready to train in minutes"
        echo "  $0 download tinystories           # 2GB, great for learning"
        echo "  $0 download openwebtext           # 38GB, serious training"
        echo "  $0 preprocess tinystories gpt2    # Tokenize for training"
        echo "  $0 estimate bookcorpus 125M       # Time estimation"
        echo
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac