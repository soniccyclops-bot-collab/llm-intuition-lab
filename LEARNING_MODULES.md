# Learning Modules Specification
**Detailed breakdown of interactive learning modules for LLM Intuition Lab**

## Module Design Philosophy

Each module follows the Emmy approach of interactive, hands-on exploration rather than passive reading. Every concept should be:
- **Manipulable** - You can change parameters and see immediate results
- **Visual** - Complex concepts are shown through interactive visualizations  
- **Explorable** - Multiple paths through the material based on curiosity
- **Grounded** - Abstract concepts tied to concrete, observable phenomena

## Module 1: Tokenization Deep Dive
**Duration:** 1-2 hours | **Difficulty:** Beginner

### Learning Objectives
- Understand why text must become numbers for ML models
- Recognize different tokenization strategies and their tradeoffs
- Develop intuition for how tokenization affects model behavior
- Build your own simple tokenizer

### Interactive Components

#### 1.1 Tokenization Playground
```clojure
(tokenization-playground 
  {:text "The quick brown fox jumps over the lazy dog"
   :tokenizers [:char-level :bpe :wordpiece :sentencepiece]
   :live-comparison true
   :metrics [:token-count :vocabulary-size :compression-ratio]})
```

**Exploration Activities:**
- Type different texts and watch tokenization in real-time
- Compare how different languages are tokenized
- Explore edge cases: punctuation, numbers, emojis, code
- Adjust BPE merge operations and see vocabulary changes

#### 1.2 Subword Mystery Solver
```clojure
(subword-explorer
  {:examples ["running" "unhappiness" "GPT-2" "COVID-19"]
   :interactive-splitter true
   :etymology-tracking true})
```

**Key Insights:**
- Why "running" becomes ["run", "ning"] but "runner" is ["runner"]
- How tokenizers handle out-of-vocabulary words
- The tradeoff between vocabulary size and token sequence length

#### 1.3 Build Your Own Tokenizer
```clojure
(tokenizer-builder
  {:corpus (load-corpus :small-english)
   :algorithm :bpe
   :vocab-size-target 1000
   :interactive-training true
   :step-by-step true})
```

**Hands-on Learning:**
- Train a BPE tokenizer from scratch on a small corpus
- Watch merge operations happen step by step
- Understand frequency-based vocabulary building
- Test your tokenizer on new text

### Assessment
- **Practical:** Predict tokenization results for novel text
- **Conceptual:** Explain when you'd choose different tokenization strategies
- **Creative:** Design a tokenizer for a specific domain (code, music notation, etc.)

---

## Module 2: Embeddings - Words as Geometry
**Duration:** 2-3 hours | **Difficulty:** Beginner to Intermediate

### Learning Objectives
- Understand how discrete tokens become continuous vectors
- Develop geometric intuition for semantic relationships
- Explore the limitations and biases in embedding spaces
- Understand contextual vs. static embeddings

### Interactive Components

#### 2.1 Embedding Space Explorer
```clojure
(embedding-space-3d
  {:model :word2vec-google-news
   :words ["king" "queen" "man" "woman" "prince" "princess"]
   :interactive-navigation true
   :similarity-visualization true
   :arithmetic-calculator true})
```

**Exploration Activities:**
- Navigate 3D embedding space with orbit controls
- Perform vector arithmetic: king - man + woman = ?
- Find nearest neighbors for any word
- Explore clustering of semantic categories

#### 2.2 Bias Detection Laboratory
```clojure
(bias-explorer
  {:embedding-model :glove-6b
   :bias-tests [:gender :racial :occupational :age]
   :interactive-measurement true
   :historical-comparison true})
```

**Critical Thinking:**
- Measure gender bias in profession-related embeddings
- Explore how training data biases affect learned representations
- Compare bias levels across different embedding models
- Understand the difference between correlation and causation

#### 2.3 Context vs. Static Embeddings
```clojure
(contextual-embedding-comparison
  {:static-model :word2vec
   :contextual-model :bert
   :ambiguous-words ["bank" "bark" "light" "right"]
   :context-sentences (generate-contexts ambiguous-words)
   :visualization :interactive-comparison})
```

**Key Discoveries:**
- How "bank" (financial) vs "bank" (river) get different vectors in BERT
- Why contextual models are more powerful but computationally expensive
- The attention mechanism's role in context-dependent representations

### Assessment
- **Geometric Reasoning:** Predict relationships using vector arithmetic
- **Bias Analysis:** Identify and measure specific biases in embeddings
- **Context Understanding:** Explain why context matters for ambiguous words

---

## Module 3: Attention - What the Model 'Sees'
**Duration:** 3-4 hours | **Difficulty:** Intermediate

### Learning Objectives
- Understand the attention mechanism's purpose and computation
- Visualize attention patterns and interpret their meaning
- Explore multi-head attention and its benefits
- Connect attention to human cognitive processes

### Interactive Components

#### 3.1 Attention Mechanism Visualizer
```clojure
(attention-visualizer
  {:model :gpt2-small
   :text "The cat that lived in the house was very old."
   :layer-selector true
   :head-selector true
   :interactive-token-highlighting true
   :step-by-step-computation true})
```

**Exploration Activities:**
- Click on any token to see what it attends to
- Watch attention patterns evolve across layers
- Compare different attention heads in the same layer
- Understand query, key, value transformations

#### 3.2 Attention Pattern Analysis Lab
```clojure
(attention-pattern-lab
  {:examples [{:text "She fed her dog. It was hungry."
               :focus :pronoun-resolution}
              {:text "The lawyer who the doctor met was tall."
               :focus :syntactic-dependencies}
              {:text "In 1969, Neil Armstrong walked on the moon."
               :focus :temporal-relationships}]
   :pattern-detection :automatic
   :manual-annotation true})
```

**Pattern Recognition:**
- Identify heads that specialize in syntax vs. semantics
- Find attention patterns for pronoun resolution
- Discover how models track long-range dependencies

#### 3.3 Multi-Head Attention Workshop
```clojure
(multi-head-workshop
  {:model :bert-base
   :text (user-input)
   :head-clustering true
   :specialization-analysis true
   :ablation-experiments true})
```

**Deep Understanding:**
- Cluster attention heads by their behavior patterns
- Run ablation studies: what happens when you disable specific heads?
- Understand why multiple heads are better than one big head

### Assessment
- **Pattern Recognition:** Identify attention patterns in novel text
- **Interpretation:** Explain what different attention heads are doing
- **Prediction:** Predict where attention should focus for specific linguistic phenomena

---

## Module 4: Transformer Architecture - The Complete System
**Duration:** 4-5 hours | **Difficulty:** Intermediate to Advanced

### Learning Objectives
- Understand how all transformer components work together
- Trace information flow through the complete architecture
- Understand the residual stream concept
- Explore different transformer variants (GPT, BERT, T5)

### Interactive Components

#### 4.1 Architecture Explorer
```clojure
(transformer-architecture-explorer
  {:model :gpt2-medium
   :visualization :interactive-network
   :layer-drill-down true
   :activation-tracking true
   :information-flow-tracing true})
```

**System Understanding:**
- Click through each layer to see its components
- Watch activations flow through the network
- Understand skip connections and layer normalization
- Explore how different layers contribute to the final output

#### 4.2 Residual Stream Analysis
```clojure
(residual-stream-analyzer
  {:model :gpt2-small
   :text "The quick brown fox"
   :layer-contributions true
   :stream-visualization true
   :intervention-experiments true})
```

**Advanced Concepts:**
- Visualize how information accumulates in the residual stream
- See which layers contribute most to specific predictions
- Run intervention experiments: what happens if you modify intermediate activations?

#### 4.3 Architecture Comparison Laboratory
```clojure
(architecture-comparison-lab
  {:models [:gpt2 :bert :t5-small]
   :comparison-dimensions [:architecture :attention-patterns :capabilities]
   :task-specific-analysis true})
```

**Comparative Analysis:**
- Understand encoder-only vs. decoder-only vs. encoder-decoder
- Compare bidirectional vs. causal attention
- See how architectural choices affect capabilities

### Assessment
- **System Thinking:** Trace how input becomes output through all layers
- **Intervention Design:** Predict effects of architectural modifications
- **Architecture Selection:** Choose appropriate architectures for different tasks

---

## Module 5: Generation - From Probability to Prose
**Duration:** 2-3 hours | **Difficulty:** Intermediate

### Learning Objectives
- Understand how models generate text token by token
- Explore different sampling strategies and their effects
- Understand the role of temperature and other generation parameters
- Connect generation strategies to creativity and coherence

### Interactive Components

#### 5.1 Generation Strategy Playground
```clojure
(generation-playground
  {:model :gpt2-medium
   :prompt (user-input)
   :strategies [:greedy :temperature :top-k :nucleus :beam-search]
   :live-parameter-adjustment true
   :generation-tree-visualization true})
```

**Hands-on Exploration:**
- Adjust temperature from 0.1 to 2.0 and see creativity changes
- Compare greedy vs. sampling strategies
- Understand the tradeoff between diversity and coherence
- Visualize the "generation tree" of possibilities

#### 5.2 Probability Distribution Explorer
```clojure
(probability-explorer
  {:model :gpt2-small
   :context "Once upon a time, there was a"
   :top-k-visualization 50
   :probability-distribution-plot true
   :interactive-sampling true})
```

**Statistical Understanding:**
- See the full probability distribution over vocabulary
- Understand how different sampling methods select from this distribution
- Explore how context affects next-token probabilities

#### 5.3 Prompt Engineering Laboratory
```clojure
(prompt-engineering-lab
  {:model :gpt2-medium
   :tasks [:creative-writing :factual-qa :code-generation]
   :prompt-templates true
   :a-b-testing true
   :effectiveness-metrics true})
```

**Practical Skills:**
- Learn effective prompting strategies
- A/B test different prompt formulations
- Understand why certain prompts work better than others

### Assessment
- **Parameter Tuning:** Optimize generation parameters for specific goals
- **Strategy Selection:** Choose appropriate sampling strategies for different use cases
- **Prompt Design:** Create effective prompts for various tasks

---

## Module 6: Scale and Emergence - Why Size Matters
**Duration:** 3-4 hours | **Difficulty:** Advanced

### Learning Objectives
- Understand scaling laws for language models
- Explore emergent abilities that appear with scale
- Understand the compute-performance relationship
- Explore the limits and future of scaling

### Interactive Components

#### 6.1 Scaling Laws Explorer
```clojure
(scaling-laws-explorer
  {:models (range-from :gpt2-small :to :gpt2-xl)
   :metrics [:loss :performance :compute-cost]
   :scaling-curves true
   :extrapolation-tool true})
```

**Quantitative Understanding:**
- Plot performance vs. model size, compute, and data
- Understand power law relationships
- Extrapolate to predict future model capabilities

#### 6.2 Emergent Abilities Detector
```clojure
(emergent-abilities-lab
  {:model-sizes [125M 350M 1.3B 2.7B 6.7B 13B]
   :tasks [:arithmetic :analogies :few-shot-learning :chain-of-thought]
   :ability-threshold-detection true})
```

**Emergence Discovery:**
- Find the model size thresholds where new abilities appear
- Understand why some abilities emerge suddenly vs. gradually
- Explore tasks that require larger models

#### 6.3 Compute vs. Performance Analysis
```clojure
(compute-performance-analyzer
  {:hardware-profiles [:rtx-3080ti :a100 :tpu-v4]
   :model-sizes (range 1B 175B)
   :efficiency-metrics true
   :cost-benefit-analysis true})
```

**Resource Understanding:**
- Understand the relationship between compute and capability
- Explore efficiency improvements (quantization, distillation)
- Make informed decisions about model size vs. resource constraints

### Assessment
- **Scaling Prediction:** Predict capabilities of future model sizes
- **Resource Planning:** Design compute-efficient solutions for specific tasks
- **Emergence Explanation:** Explain why certain abilities emerge with scale

---

## Cross-Module Integration Projects

### Project 1: Build Your Own Mini-LLM
Combine knowledge from all modules to:
- Design a small transformer architecture
- Implement tokenization and embedding layers
- Add attention mechanisms
- Train on a small corpus
- Evaluate generation quality

### Project 2: Model Behavior Analysis
Choose a specific model behavior and:
- Design experiments to understand the mechanism
- Use attention analysis and activation investigation
- Form and test hypotheses about the underlying computation
- Present findings with visualizations

### Project 3: Efficiency Optimization Challenge
Given hardware constraints:
- Analyze model requirements vs. available resources
- Implement optimization strategies (quantization, pruning)
- Measure performance vs. efficiency tradeoffs
- Design a deployment strategy

## Assessment Philosophy

Assessment in LLM Intuition Lab focuses on:

### Understanding Over Memorization
- Can you predict model behavior in new situations?
- Can you explain why certain phenomena occur?
- Can you design experiments to test your hypotheses?

### Practical Application
- Can you choose appropriate models and parameters for specific tasks?
- Can you optimize model deployment for given constraints?
- Can you identify and mitigate model limitations and biases?

### Critical Thinking
- Can you evaluate claims about model capabilities?
- Can you identify the assumptions underlying different approaches?
- Can you design better solutions based on understanding principles?

Each module includes both formative assessment (interactive exercises) and summative assessment (applied projects) to ensure deep understanding rather than surface-level familiarity.