# OpenCode Programming Persona Plugin - Installation Guide

## 🚀 Ready-to-Use Implementation

Drop-in plugin that adds global programming personality to OpenCode without any code changes.

## 📦 Installation

### 1. Create OpenCode Plugin Directory
```bash
mkdir -p ~/.opencode/plugins
```

### 2. Install the Plugin
```bash
# Copy the programming-persona.ts file to your plugins directory
cp programming-persona.ts ~/.opencode/plugins/

# Create or update your OpenCode configuration
cat > ~/.opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "./plugins/programming-persona.ts"
  ]
}
EOF
```

### 3. Verify Installation
```bash
# Start OpenCode in any repository
opencode

# Check if the plugin is loaded
/personality-status
```

## 🧠 Taking the Personality Quiz

### Start the Assessment
```bash
opencode
/personality-quiz
```

The quiz will:
1. **Present dynamic code examples** for you to critique
2. **Ask follow-up questions** based on your detailed responses  
3. **Extract your programming philosophy** from the conversation
4. **Create a global personality profile** saved to `~/.opencode/programming-persona.json`

### Quiz Flow Example
```
🧠 Programming Personality Assessment

Category: Language Philosophy
Here are three approaches to choosing between Python, Go, and Rust for a CLI tool:

[Dynamic code examples generated]

Please analyze each approach:
1. Which approach resonates most with your coding style and why?
2. What specific aspects do you like or dislike?
...

> /quiz-respond "I prefer the Rust approach because..."

[Follow-up questions generated based on your response]

> /quiz-respond "In my experience with a payment system..."

[Continues through 6 categories, then extracts personality]

🎉 Programming Personality Assessment Complete!
Your personality is now active across all repositories!
```

### Categories Covered
- **Language Philosophy** - Error handling, type systems, language selection
- **Architecture Patterns** - Monoliths vs microservices, system design
- **Testing Strategy** - Unit vs integration, testing philosophy  
- **Code Organization** - Project structure, modularity approaches
- **Performance Optimization** - When and how to optimize
- **Error Handling** - Exception vs result types, failure strategies

## ✅ Automatic Application

Once configured, your personality automatically applies to **every OpenCode session**:

### Smart Context Adaptation
- **Startup/MVP projects** → Speed-focused with intentional debt tracking
- **Enterprise systems** → Quality and maintainability emphasis  
- **Open source projects** → Contributor-friendly with extensive docs
- **Research prototypes** → Exploration over optimization

### Project Detection
The plugin automatically analyzes:
- Package.json dependency count and scripts
- Presence of testing, linting, documentation files
- README, LICENSE, CONTRIBUTING files
- Notebook files for research projects

### Personality Injection
```typescript
// Your personality gets injected into every agent prompt
const personalityPrompt = `
# Programming Personality Context

## Core Identity: pragmatic_with_standards

You are an AI coding assistant with a specific programming personality...

### Technical Philosophy
- Architecture Approach: evolutionary_design
- Problem Solving: systematic_experimentation
- Code Quality: maintainable_and_readable

### Project Context Adaptation (startup_mvp)
- Prioritize delivery speed while tracking technical debt intentionally
- Test critical user paths and edge cases primarily  
- Provide concrete, runnable examples over extensive documentation
...
`
```

## 🔧 Management Commands

### View Your Profile
```bash
/personality-show
```
Displays your complete programming personality with current project adaptations.

### Check System Status  
```bash
/personality-status
```
Shows personality configuration status, current project analysis, and available commands.

### Reset and Start Over
```bash
/personality-reset
```
Clears your personality profile so you can take a fresh assessment.

## 📁 File Structure

After installation and quiz completion:
```
~/.opencode/
├── opencode.json                    # Plugin configuration
├── plugins/
│   └── programming-persona.ts       # The plugin implementation
├── programming-persona.json         # Your extracted personality
└── quiz-state.json                  # Temporary quiz state (auto-deleted)
```

## 🎯 Example Personality Profile

```json
{
  "meta": {
    "version": "1.0.0",
    "createdAt": "2026-03-23T14:00:00.000Z",
    "quizTaken": true
  },
  "personality": {
    "core_identity": {
      "programming_approach": "pragmatic_with_standards",
      "architecture_philosophy": "evolutionary_design",
      "code_quality_mindset": "maintainable_and_readable",
      "problem_solving_style": "systematic_experimentation"
    },
    "technical_preferences": {
      "language_selection": "right_tool_for_job",
      "type_systems": "strong_static_preferred",
      "error_handling": "explicit_result_types",
      "testing_approach": "risk_based_comprehensive"
    },
    "communication_style": {
      "tone": "direct_and_helpful",
      "explanation_depth": "progressive_disclosure",
      "documentation_style": "code_tells_story_comments_explain_why"
    },
    "collaboration_preferences": {
      "decision_making": "constraint_based_not_opinion_based",
      "technical_discussions": "show_dont_tell_with_examples"
    }
  },
  "context_adaptations": {
    "project_types": {
      "startup_mvp": {
        "speed_vs_quality": "speed_with_intentional_debt",
        "testing_level": "critical_paths_only", 
        "documentation": "runnable_examples_over_comprehensive"
      },
      "enterprise_system": {
        "speed_vs_quality": "quality_and_maintainability_first",
        "testing_level": "comprehensive_with_edge_cases",
        "documentation": "comprehensive_architectural_decisions"  
      }
    }
  }
}
```

## 🔍 How Personality Injection Works

### 1. Session Hook
```typescript
agent: {
  async "*"(context, next) {
    const personality = await loadPersonality()
    if (!personality) return next()
    
    const projectType = await detectProjectType(directory)
    const personalityPrompt = generatePersonalityPrompt(personality, projectType)
    
    // Enhance the agent prompt with personality context
    context.agent.prompt = `${personalityPrompt}\n\n${context.agent.prompt || ""}`
    
    return next()
  }
}
```

### 2. Project Analysis
```typescript
async function detectProjectType(directory: string): Promise<string> {
  // Analyzes package.json, README, dependencies, scripts
  // Returns: startup_mvp | enterprise_system | open_source | research_prototype
}
```

### 3. Dynamic Prompt Generation
The plugin generates a personality-enhanced prompt that includes:
- Your core programming identity and preferences
- Technical approach patterns
- Communication style guidelines  
- Project-specific adaptations
- Decision-making frameworks

## 🎖️ Benefits

### ✅ **Zero Configuration Overhead**
- One quiz, works everywhere automatically
- No per-repository AGENTS.md setup needed
- Consistent experience across all projects

### ✅ **Authentic Programming Style**
- Extracted through interactive assessment, not static forms
- Captures real decision-making patterns
- Evolves through conversation and critique

### ✅ **Smart Context Awareness**  
- Automatically adapts to project type and team dynamics
- Maintains individual style while respecting context
- Balances personal preferences with project needs

### ✅ **Pure Plugin Architecture**
- No OpenCode core changes required
- Easy installation and removal
- Leverages existing OpenCode plugin system

This makes OpenCode the **first AI coding tool with persistent, authentic programming personality** that travels with you everywhere while adapting intelligently to different contexts! 🚀