# OpenCode Programming Personality Plugin
**Drop-in personality system for OpenCode AI coding agent**

## 🎯 What This Is

A **plugin for OpenCode** that adds global programming personality without needing to fork the codebase. You drop it into `~/.opencode/plugins/` and it automatically:

1. Takes the dynamic programming philosophy quiz
2. Extracts your authentic coding personality
3. Applies that personality across ALL repositories automatically
4. Enhances local AGENTS.md with your global coding preferences

## 🏗️ Plugin Architecture

OpenCode's plugin system allows us to:
- Hook into session initialization 
- Modify agent configurations dynamically
- Add new commands and tools
- Store global configuration data

### Plugin Structure
```
~/.opencode/
├── plugins/
│   └── programming-persona.ts    # The personality plugin
├── opencode.json                 # Enable the plugin
└── programming-persona.json      # Your extracted personality
```

## 🔧 Implementation

### Main Plugin File: `~/.opencode/plugins/programming-persona.ts`

```typescript
import { Plugin } from "@opencode-ai/plugin"
import path from "path"
import fs from "fs/promises"
import { homedir } from "os"

interface ProgrammingPersonality {
  meta: {
    version: string
    createdAt: string
    lastUpdatedAt: string
    quizTaken: boolean
  }
  personality: {
    core_identity: {
      programming_approach: string
      problem_solving_style: string
      architecture_philosophy: string
      code_quality_mindset: string
    }
    technical_preferences: {
      language_selection: string
      type_systems: string
      error_handling: string
      testing_approach: string
      performance_philosophy: string
    }
    communication_style: {
      explanation_depth: string
      tone: string
      documentation_style: string
      feedback_preference: string
    }
    workflow_patterns: {
      git_workflow: string
      code_review_focus: string
      refactoring_timing: string
      debugging_method: string
    }
    collaboration_preferences: {
      decision_making: string
      technical_discussions: string
      knowledge_sharing: string
      conflict_resolution: string
    }
  }
  context_adaptations: {
    project_types: {
      [key: string]: {
        speed_vs_quality: string
        testing_level: string
        documentation: string
      }
    }
  }
}

const ProgrammingPersonaPlugin: Plugin = async ({ client, project, directory }) => {
  const personalityPath = path.join(homedir(), ".opencode", "programming-persona.json")

  async function loadPersonality(): Promise<ProgrammingPersonality | null> {
    try {
      const data = await fs.readFile(personalityPath, 'utf-8')
      return JSON.parse(data)
    } catch {
      return null
    }
  }

  async function savePersonality(personality: ProgrammingPersonality): Promise<void> {
    await fs.writeFile(personalityPath, JSON.stringify(personality, null, 2))
  }

  async function detectProjectType(directory: string): Promise<string> {
    try {
      const packageJsonPath = path.join(directory, 'package.json')
      const packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf-8'))
      
      // Detect startup/MVP
      const hasMinimalDeps = Object.keys(packageJson.dependencies || {}).length < 20
      const hasDevScript = packageJson.scripts?.dev || packageJson.scripts?.start
      
      if (hasMinimalDeps && hasDevScript) {
        return 'startup_mvp'
      }

      // Detect enterprise
      const hasExtensiveDeps = Object.keys(packageJson.dependencies || {}).length > 50
      const hasTestScript = packageJson.scripts?.test
      const hasLinting = packageJson.devDependencies?.eslint || packageJson.devDependencies?.prettier
      
      if (hasExtensiveDeps && hasTestScript && hasLinting) {
        return 'enterprise_system'
      }

      // Check for open source indicators
      const readmePath = path.join(directory, 'README.md')
      const hasReadme = await fs.access(readmePath).then(() => true).catch(() => false)
      const hasLicense = await fs.access(path.join(directory, 'LICENSE')).then(() => true).catch(() => false)
      
      if (hasReadme && hasLicense) {
        return 'open_source'
      }

      return 'general_development'
    } catch {
      return 'general_development'
    }
  }

  function generatePersonalityPrompt(personality: ProgrammingPersonality, projectType: string): string {
    const adaptation = personality.context_adaptations.project_types[projectType] || 
                      personality.context_adaptations.project_types['general_development']

    return `# Programming Personality Context

## Core Identity: ${personality.personality.core_identity.programming_approach}

You are an AI coding assistant with a specific programming personality that has been extracted from an in-depth assessment of the developer's authentic coding preferences and decision-making patterns.

### Technical Philosophy
- **Architecture Approach**: ${personality.personality.core_identity.architecture_philosophy}
- **Problem Solving**: ${personality.personality.core_identity.problem_solving_style}
- **Code Quality**: ${personality.personality.core_identity.code_quality_mindset}

### Technical Preferences  
- **Language Selection**: ${personality.personality.technical_preferences.language_selection}
- **Type Systems**: ${personality.personality.technical_preferences.type_systems}
- **Error Handling**: ${personality.personality.technical_preferences.error_handling}
- **Testing**: ${personality.personality.technical_preferences.testing_approach}

### Communication Style
- **Tone**: ${personality.personality.communication_style.tone}
- **Explanation Depth**: ${personality.personality.communication_style.explanation_depth}
- **Documentation**: ${personality.personality.communication_style.documentation_style}

### Decision Making Pattern
${personality.personality.collaboration_preferences.decision_making === 'constraint_based_not_opinion_based' 
  ? `Approach technical decisions systematically:
1. Understand the real constraints and requirements
2. Consider multiple approaches with concrete examples
3. Evaluate tradeoffs explicitly based on project context  
4. Choose based on evidence and constraints, not opinions
5. Ship and learn from real usage`
  : 'Use collaborative consensus-building for technical decisions'}

### Project Context Adaptation (${projectType})
${adaptation.speed_vs_quality === 'speed_with_intentional_debt' 
  ? '- Prioritize delivery speed while tracking technical debt intentionally'
  : '- Focus on maintainable, production-ready solutions'}
${adaptation.testing_level === 'critical_paths_only'
  ? '- Test critical user paths and edge cases primarily'  
  : '- Implement comprehensive testing with edge case coverage'}
${adaptation.documentation === 'runnable_examples_over_comprehensive'
  ? '- Provide concrete, runnable examples over extensive documentation'
  : '- Create thorough documentation and architectural decision records'}

### Interaction Guidelines
- Be ${personality.personality.communication_style.tone.replace('_', ' ')}
- Match the developer's authentic programming style and preferences  
- Adapt recommendations to the detected project context
- Focus on ${personality.personality.collaboration_preferences.technical_discussions.replace('_', ' ')}
- Provide ${personality.personality.communication_style.feedback_preference.replace('_', ' ')}

This personality profile was generated from an interactive programming philosophy assessment and should guide all technical recommendations and communication patterns.`
  }

  return {
    // Hook into agent configuration to inject personality
    agent: {
      async "*"(context, next) {
        const personality = await loadPersonality()
        
        if (!personality) {
          // No personality configured yet - offer to take quiz
          return next()
        }

        const projectType = await detectProjectType(directory)
        const personalityPrompt = generatePersonalityPrompt(personality, projectType)
        
        // Inject personality into the agent prompt
        const originalPrompt = context.agent.prompt || ""
        context.agent.prompt = `${personalityPrompt}\n\n${originalPrompt}`
        
        return next()
      }
    },

    // Add personality management commands
    tool: {
      "personality-quiz": {
        description: "Take the programming philosophy assessment to configure your global coding personality",
        async execute() {
          return `🧠 Programming Personality Quiz

I'll conduct an interactive assessment to understand your authentic programming philosophy and preferences. This will create a global personality that applies across all your repositories.

The quiz uses dynamic code generation - I'll create specific examples and scenarios based on your responses, then extract your programming personality from the discussion.

Ready to start? I'll begin with some code examples for you to critique...

---

**Category: Language Philosophy**

Here are three approaches to error handling in a CLI tool for processing user data:

\`\`\`go
// Approach A: Traditional error handling
func processUserData(data string) (Result, error) {
    if len(data) == 0 {
        return Result{}, errors.New("empty data provided")
    }
    
    parsed, err := parseData(data)
    if err != nil {
        return Result{}, fmt.Errorf("parsing failed: %w", err)
    }
    
    validated, err := validateData(parsed)
    if err != nil {
        return Result{}, fmt.Errorf("validation failed: %w", err)
    }
    
    return processValidData(validated), nil
}
\`\`\`

\`\`\`rust
// Approach B: Result type with chaining
fn process_user_data(data: &str) -> Result<ProcessedData, ProcessingError> {
    validate_input(data)?
        .parse_data()?
        .validate_business_rules()?
        .transform_to_output()
}

#[derive(Debug, thiserror::Error)]
enum ProcessingError {
    #[error("Input validation failed: {reason}")]
    InvalidInput { reason: String },
    #[error("Parse error: {source}")]
    ParseError { source: ParseError },
    #[error("Business rule violation: {rule}")]
    BusinessRuleViolation { rule: String },
}
\`\`\`

\`\`\`python
// Approach C: Exception handling with context
def process_user_data(data: str) -> ProcessedData:
    try:
        if not data.strip():
            raise ValueError("Empty or whitespace-only data provided")
            
        parsed = parse_data(data)
        validated = validate_data(parsed)
        return process_validated_data(validated)
        
    except ParseError as e:
        raise ProcessingError(f"Failed to parse data: {e}") from e
    except ValidationError as e:
        raise ProcessingError(f"Data validation failed: {e}") from e
    except Exception as e:
        logger.exception("Unexpected error processing user data")
        raise ProcessingError("Internal processing error") from e
\`\`\`

**Please analyze each approach:**
1. Which approach resonates most with your coding style and why?
2. What specific aspects do you like or dislike about each implementation?
3. How would you modify your preferred approach for this specific use case?
4. What are the tradeoffs you see between these different error handling philosophies?

Take your time and be specific about your reasoning. Your detailed response will help me understand your authentic programming preferences.`
        }
      },

      "personality-show": {
        description: "Display your current programming personality profile",
        async execute() {
          const personality = await loadPersonality()
          
          if (!personality) {
            return "No programming personality configured. Run `/personality-quiz` to take the assessment."
          }

          return `# Your Programming Personality Profile

**Generated**: ${new Date(personality.meta.createdAt).toLocaleDateString()}
**Last Updated**: ${new Date(personality.meta.lastUpdatedAt).toLocaleDateString()}

## Core Identity
- **Programming Approach**: ${personality.personality.core_identity.programming_approach}
- **Architecture Philosophy**: ${personality.personality.core_identity.architecture_philosophy}  
- **Code Quality Mindset**: ${personality.personality.core_identity.code_quality_mindset}
- **Problem Solving Style**: ${personality.personality.core_identity.problem_solving_style}

## Technical Preferences
- **Language Selection**: ${personality.personality.technical_preferences.language_selection}
- **Type Systems**: ${personality.personality.technical_preferences.type_systems}
- **Error Handling**: ${personality.personality.technical_preferences.error_handling}
- **Testing Approach**: ${personality.personality.technical_preferences.testing_approach}

## Communication Style
- **Tone**: ${personality.personality.communication_style.tone}
- **Explanation Depth**: ${personality.personality.communication_style.explanation_depth}
- **Documentation Style**: ${personality.personality.communication_style.documentation_style}

## Project Adaptations
${Object.entries(personality.context_adaptations.project_types).map(([type, config]) => 
  `### ${type.replace('_', ' ')}
- Speed vs Quality: ${config.speed_vs_quality}
- Testing Level: ${config.testing_level}  
- Documentation: ${config.documentation}`
).join('\n\n')}

This personality is automatically applied to all OpenCode sessions across all repositories.`
        }
      },

      "personality-reset": {
        description: "Reset your programming personality and retake the assessment",
        async execute() {
          try {
            await fs.unlink(personalityPath)
            return "Programming personality reset! Run `/personality-quiz` to configure a new personality profile."
          } catch {
            return "No personality profile found to reset."
          }
        }
      }
    }
  }
}

export default ProgrammingPersonaPlugin
```

### Configuration: `~/.opencode/opencode.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "./plugins/programming-persona.ts"
  ]
}
```

## 🚀 Installation & Usage

### 1. Install the Plugin

```bash
# Create the OpenCode config directory
mkdir -p ~/.opencode/plugins

# Add the plugin file (copy the programming-persona.ts content above)
# Then enable it in config
echo '{
  "$schema": "https://opencode.ai/config.json", 
  "plugin": ["./plugins/programming-persona.ts"]
}' > ~/.opencode/opencode.json
```

### 2. Take the Personality Quiz

```bash
# Start OpenCode in any repository
opencode

# Take the personality assessment  
/personality-quiz
```

The quiz will:
- Generate dynamic code examples based on your responses
- Ask follow-up questions when you give detailed answers
- Extract your authentic programming philosophy
- Save it to `~/.opencode/programming-persona.json`

### 3. Automatic Application

Once configured, your programming personality automatically applies to **every OpenCode session**:

- **Startup repos**: Focus on speed with intentional tech debt
- **Enterprise codebases**: Emphasize maintainability and testing
- **Open source projects**: Prioritize contributor experience
- **Research prototypes**: Enable exploration and experimentation

### 4. Management Commands

```bash
/personality-show    # View your current personality profile
/personality-reset   # Reset and retake the quiz
```

## 💡 How It Works

### Personality Injection
The plugin hooks into OpenCode's agent initialization and:
1. Loads your global personality from `~/.opencode/programming-persona.json`
2. Detects the current project type (startup, enterprise, open source, research)
3. Generates a personality-enhanced prompt that gets prepended to any local AGENTS.md
4. Applies context-aware adaptations based on project characteristics

### Project Type Detection
```typescript
async function detectProjectType(directory: string): Promise<string> {
  // Analyzes package.json, README, license files, dependency count,
  // testing setup, and other indicators to classify project type
}
```

### Dynamic Quiz System
The `/personality-quiz` tool launches an interactive assessment that:
- Generates code examples based on your responses
- Asks follow-up questions for detailed answers
- Builds a conversation history to extract authentic preferences
- Saves the extracted personality for global application

## 🎖️ Benefits

### ✅ **No Fork Required**
- Pure plugin implementation using OpenCode's existing architecture
- Drop-in installation to `~/.opencode/`
- No need to maintain a separate codebase

### ✅ **Cross-Repository Consistency**  
- One quiz, applied everywhere automatically
- Consistent coding assistance across all projects
- Context-aware adaptation to different project types

### ✅ **Authentic Personality**
- Dynamic quiz with agent-generated scenarios
- Extracts genuine programming preferences
- Evolves through conversation rather than static forms

### ✅ **Smart Context Adaptation**
- Automatically detects project characteristics
- Adapts personality to match project needs
- Maintains individual style while respecting context

This plugin would make OpenCode the **first AI coding tool with persistent, authentic programming personality** that travels with you across all repositories while adapting intelligently to different contexts - all without requiring any changes to the core OpenCode codebase! 🚀