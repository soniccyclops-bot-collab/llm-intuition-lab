import { type Plugin } from "@opencode-ai/plugin"
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

interface QuizState {
  currentCategory: string
  responses: Array<{
    category: string
    question: string
    response: string
    timestamp: string
  }>
  stage: "intro" | "questioning" | "follow_up" | "extraction" | "complete"
  followUpContext?: string
}

const ProgrammingPersonaPlugin: Plugin = async ({ client, project, directory }) => {
  const personalityPath = path.join(homedir(), ".opencode", "programming-persona.json")
  const quizStatePath = path.join(homedir(), ".opencode", "quiz-state.json")

  async function loadPersonality(): Promise<ProgrammingPersonality | null> {
    try {
      const data = await fs.readFile(personalityPath, 'utf-8')
      return JSON.parse(data)
    } catch {
      return null
    }
  }

  async function savePersonality(personality: ProgrammingPersonality): Promise<void> {
    await fs.mkdir(path.dirname(personalityPath), { recursive: true })
    await fs.writeFile(personalityPath, JSON.stringify(personality, null, 2))
  }

  async function loadQuizState(): Promise<QuizState | null> {
    try {
      const data = await fs.readFile(quizStatePath, 'utf-8')
      return JSON.parse(data)
    } catch {
      return null
    }
  }

  async function saveQuizState(state: QuizState): Promise<void> {
    await fs.mkdir(path.dirname(quizStatePath), { recursive: true })
    await fs.writeFile(quizStatePath, JSON.stringify(state, null, 2))
  }

  async function clearQuizState(): Promise<void> {
    try {
      await fs.unlink(quizStatePath)
    } catch {
      // File doesn't exist, that's fine
    }
  }

  async function detectProjectType(directory: string): Promise<string> {
    try {
      const packageJsonPath = path.join(directory, 'package.json')
      let packageJson: any = {}
      
      try {
        packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf-8'))
      } catch {
        // No package.json, continue with other checks
      }
      
      const depCount = Object.keys(packageJson.dependencies || {}).length
      const devDepCount = Object.keys(packageJson.devDependencies || {}).length
      const scripts = packageJson.scripts || {}
      
      // Check for various project indicators
      const hasDevScript = scripts.dev || scripts.start || scripts.serve
      const hasTestScript = scripts.test || scripts.jest || scripts.vitest
      const hasLinting = packageJson.devDependencies?.eslint || 
                         packageJson.devDependencies?.prettier ||
                         packageJson.devDependencies?.typescript
      const hasE2E = packageJson.devDependencies?.playwright ||
                     packageJson.devDependencies?.cypress ||
                     packageJson.devDependencies?.selenium
      
      // Check for additional files
      const readmePath = path.join(directory, 'README.md')
      const licensePath = path.join(directory, 'LICENSE')
      const contributingPath = path.join(directory, 'CONTRIBUTING.md')
      
      const hasReadme = await fs.access(readmePath).then(() => true).catch(() => false)
      const hasLicense = await fs.access(licensePath).then(() => true).catch(() => false)
      const hasContributing = await fs.access(contributingPath).then(() => true).catch(() => false)
      
      // Check for notebook files (research indicators)
      const hasNotebooks = await fs.readdir(directory)
        .then(files => files.some(f => f.endsWith('.ipynb') || f.endsWith('.Rmd')))
        .catch(() => false)
      
      // Detect startup/MVP (minimal deps, dev-focused)
      if (depCount < 20 && hasDevScript && !hasE2E && !hasContributing) {
        return 'startup_mvp'
      }

      // Detect enterprise (extensive deps, comprehensive tooling)
      if (depCount > 50 && hasTestScript && hasLinting && hasE2E) {
        return 'enterprise_system'
      }

      // Detect open source (documentation, licensing)
      if (hasReadme && hasLicense && hasContributing) {
        return 'open_source'
      }

      // Detect research (notebooks, data files)
      if (hasNotebooks) {
        return 'research_prototype'
      }

      return 'general_development'
    } catch {
      return 'general_development'
    }
  }

  function generatePersonalityPrompt(personality: ProgrammingPersonality, projectType: string): string {
    const adaptation = personality.context_adaptations.project_types[projectType] || 
                      personality.context_adaptations.project_types['general_development'] ||
                      {
                        speed_vs_quality: 'balanced_approach',
                        testing_level: 'pragmatic_coverage',
                        documentation: 'clear_and_concise'
                      }

    return `# Programming Personality Context

You are an AI coding assistant with a specific programming personality that has been extracted from an in-depth assessment of the developer's authentic coding preferences and decision-making patterns.

## Core Identity: ${personality.personality.core_identity.programming_approach}

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

### Project Context Adaptation (${projectType.replace('_', ' ')})
${adaptation.speed_vs_quality === 'speed_with_intentional_debt' 
  ? '- Prioritize delivery speed while tracking technical debt intentionally'
  : adaptation.speed_vs_quality === 'quality_and_maintainability_first'
  ? '- Focus on maintainable, production-ready solutions'
  : '- Balance speed and quality based on project needs'}
${adaptation.testing_level === 'critical_paths_only'
  ? '- Test critical user paths and edge cases primarily'  
  : adaptation.testing_level === 'comprehensive_with_edge_cases'
  ? '- Implement comprehensive testing with edge case coverage'
  : '- Apply pragmatic testing strategies based on risk'}
${adaptation.documentation === 'runnable_examples_over_comprehensive'
  ? '- Provide concrete, runnable examples over extensive documentation'
  : adaptation.documentation === 'comprehensive_architectural_decisions'
  ? '- Create thorough documentation and architectural decision records'
  : '- Maintain clear and concise documentation'}

### Interaction Guidelines
- Be ${personality.personality.communication_style.tone.replace('_', ' ')}
- Match the developer's authentic programming style and preferences  
- Adapt recommendations to the detected project context
- Focus on ${personality.personality.collaboration_preferences.technical_discussions.replace('_', ' ')}
- Provide ${personality.personality.communication_style.feedback_preference.replace('_', ' ')}

This personality profile was generated from an interactive programming philosophy assessment and should guide all technical recommendations and communication patterns.
`
  }

  const quizCategories = [
    {
      name: "Language Philosophy",
      topic: "choosing between Python, Go, and Rust for a CLI tool"
    },
    {
      name: "Architecture Patterns", 
      topic: "microservices vs monolith for an e-commerce platform"
    },
    {
      name: "Error Handling",
      topic: "exception handling vs result types in payment processing"
    },
    {
      name: "Testing Strategy",
      topic: "unit testing vs integration testing for business logic"
    },
    {
      name: "Code Organization",
      topic: "organizing a large web application codebase"
    },
    {
      name: "Performance Optimization",
      topic: "caching strategies for high-traffic endpoints"
    }
  ]

  function generateQuizQuestion(category: string, topic: string, responses: any[]): string {
    const contextFromPrevious = responses.length > 0 ? 
      `\n\nBased on your previous responses, I notice you lean towards ${responses[responses.length - 1]?.response?.substring(0, 100)}...\n` : ''

    switch (category) {
      case "Language Philosophy":
        return `**Category: Language Philosophy**
${contextFromPrevious}
Here are three approaches to ${topic}:

\`\`\`go
// Approach A: Go implementation
package main

import (
    "flag"
    "fmt"
    "log"
    "os"
)

func main() {
    var input = flag.String("input", "", "input file path")
    var output = flag.String("output", "", "output file path")
    flag.Parse()
    
    if *input == "" {
        log.Fatal("input file is required")
    }
    
    data, err := os.ReadFile(*input)
    if err != nil {
        log.Fatalf("failed to read input: %v", err)
    }
    
    result := processData(string(data))
    
    if *output != "" {
        err = os.WriteFile(*output, []byte(result), 0644)
        if err != nil {
            log.Fatalf("failed to write output: %v", err)
        }
    } else {
        fmt.Print(result)
    }
}

func processData(data string) string {
    // Process data here
    return data
}
\`\`\`

\`\`\`rust
// Approach B: Rust implementation
use clap::{Arg, Command};
use std::fs;
use std::io::{self, Write};
use thiserror::Error;

#[derive(Error, Debug)]
enum CliError {
    #[error("IO error: {0}")]
    Io(#[from] io::Error),
    #[error("Processing error: {message}")]
    Processing { message: String },
}

fn main() -> Result<(), CliError> {
    let matches = Command::new("cli-tool")
        .arg(Arg::new("input")
            .short('i')
            .long("input")
            .value_name("FILE")
            .required(true))
        .arg(Arg::new("output")
            .short('o')
            .long("output")
            .value_name("FILE"))
        .get_matches();

    let input_path = matches.get_one::<String>("input").unwrap();
    let output_path = matches.get_one::<String>("output");

    let data = fs::read_to_string(input_path)?;
    let result = process_data(&data)?;

    match output_path {
        Some(path) => fs::write(path, result)?,
        None => print!("{}", result),
    }

    Ok(())
}

fn process_data(data: &str) -> Result<String, CliError> {
    // Process data here
    Ok(data.to_string())
}
\`\`\`

\`\`\`python
// Approach C: Python implementation
#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
from typing import Optional

class CliError(Exception):
    """Custom exception for CLI errors"""
    pass

def process_data(data: str) -> str:
    """Process the input data"""
    # Process data here
    return data

def main() -> None:
    parser = argparse.ArgumentParser(description='CLI data processing tool')
    parser.add_argument('-i', '--input', required=True, type=Path,
                       help='Input file path')
    parser.add_argument('-o', '--output', type=Path,
                       help='Output file path')
    
    args = parser.parse_args()
    
    try:
        if not args.input.exists():
            raise CliError(f"Input file {args.input} does not exist")
            
        data = args.input.read_text()
        result = process_data(data)
        
        if args.output:
            args.output.write_text(result)
        else:
            print(result, end='')
            
    except CliError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
\`\`\`

**Please analyze each approach:**
1. Which approach resonates most with your coding style and why?
2. What specific aspects do you like or dislike about each implementation?
3. How would you modify your preferred approach for this specific use case?
4. What are the tradeoffs you see between these different language philosophies?

Be detailed in your reasoning - your response helps me understand your authentic programming preferences.`

      case "Architecture Patterns":
        return `**Category: Architecture Patterns**
${contextFromPrevious}
Here are three architectural approaches for ${topic}:

\`\`\`typescript
// Approach A: Modular Monolith
// Single deployment with clear domain boundaries

// src/domains/user/user.service.ts
export class UserService {
  constructor(
    private userRepo: UserRepository,
    private eventBus: DomainEventBus
  ) {}

  async createUser(userData: CreateUserData): Promise<User> {
    const user = new User(userData)
    await this.userRepo.save(user)
    
    await this.eventBus.publish(new UserCreatedEvent(user.id))
    return user
  }
}

// src/domains/product/product.service.ts  
export class ProductService {
  constructor(
    private productRepo: ProductRepository,
    private inventoryService: InventoryService
  ) {}

  async createProduct(productData: CreateProductData): Promise<Product> {
    const product = new Product(productData)
    await this.productRepo.save(product)
    await this.inventoryService.initialize(product.id)
    return product
  }
}

// Single database, domain boundaries enforced by architecture
\`\`\`

\`\`\`yaml
# Approach B: Microservices
version: '3.8'
services:
  user-service:
    image: ecommerce/user-service
    environment:
      - DATABASE_URL=postgres://user-db:5432/users
    depends_on:
      - user-db
      - message-bus

  product-service:
    image: ecommerce/product-service
    environment:
      - DATABASE_URL=postgres://product-db:5432/products
    depends_on:
      - product-db
      - message-bus

  order-service:
    image: ecommerce/order-service
    environment:
      - DATABASE_URL=postgres://order-db:5432/orders
      - USER_SERVICE_URL=http://user-service:3000
      - PRODUCT_SERVICE_URL=http://product-service:3000
    depends_on:
      - order-db
      - message-bus

  api-gateway:
    image: ecommerce/api-gateway
    ports:
      - "80:80"
    environment:
      - USER_SERVICE_URL=http://user-service:3000
      - PRODUCT_SERVICE_URL=http://product-service:3000
      - ORDER_SERVICE_URL=http://order-service:3000

  message-bus:
    image: rabbitmq:management
    
  # Separate databases per service
  user-db:
    image: postgres:14
  product-db:
    image: postgres:14
  order-db:
    image: postgres:14
\`\`\`

\`\`\`python
# Approach C: Hybrid - Services with Shared Data Layer
# Multiple services, strategic data sharing

# user_service/main.py
from shared.database import get_db_connection
from shared.events import EventBus

class UserService:
    def __init__(self):
        self.db = get_db_connection("users")
        self.events = EventBus()
    
    async def create_user(self, user_data):
        async with self.db.transaction():
            user = await self.db.users.insert(user_data)
            await self.events.publish("user.created", user)
            return user

# product_service/main.py  
from shared.database import get_db_connection
from shared.events import EventBus

class ProductService:
    def __init__(self):
        self.db = get_db_connection("products")
        self.events = EventBus()
        
    async def create_product(self, product_data):
        async with self.db.transaction():
            product = await self.db.products.insert(product_data)
            await self.events.publish("product.created", product)
            return product

# order_service/main.py
from shared.database import get_db_connection
from shared.events import EventBus

class OrderService:
    def __init__(self):
        self.db = get_db_connection("orders")
        self.user_db = get_db_connection("users", readonly=True)
        self.product_db = get_db_connection("products", readonly=True)
        self.events = EventBus()
        
    async def create_order(self, order_data):
        # Can read user and product data directly
        user = await self.user_db.users.find_by_id(order_data.user_id)
        products = await self.product_db.products.find_by_ids(order_data.product_ids)
        
        async with self.db.transaction():
            order = await self.db.orders.insert(order_data)
            await self.events.publish("order.created", order)
            return order
\`\`\`

**Please analyze each approach:**
1. Which architectural style aligns with your design philosophy and why?
2. What are the specific benefits and drawbacks you see in each approach?
3. How would you handle cross-cutting concerns like authentication, logging, and monitoring in your preferred approach?
4. What factors would influence your decision between these architectures for a real project?

Your detailed analysis helps me understand how you think about system design and architecture tradeoffs.`

      default:
        return `**Category: ${category}**
${contextFromPrevious}
Let's explore ${topic}. I'll generate specific examples based on our conversation...

[Dynamic content would be generated here based on the category and previous responses]

Please share your thoughts on this scenario and explain your reasoning in detail.`
    }
  }

  function extractPersonalityFromResponses(responses: any[]): ProgrammingPersonality {
    // This is a simplified extraction - in a real implementation,
    // this would use more sophisticated analysis
    
    const personality: ProgrammingPersonality = {
      meta: {
        version: "1.0.0",
        createdAt: new Date().toISOString(),
        lastUpdatedAt: new Date().toISOString(),
        quizTaken: true
      },
      personality: {
        core_identity: {
          programming_approach: "pragmatic_with_standards",
          problem_solving_style: "systematic_experimentation",
          architecture_philosophy: "evolutionary_design",
          code_quality_mindset: "maintainable_and_readable"
        },
        technical_preferences: {
          language_selection: "right_tool_for_job",
          type_systems: "strong_static_preferred",
          error_handling: "explicit_result_types",
          testing_approach: "risk_based_comprehensive",
          performance_philosophy: "measure_then_optimize"
        },
        communication_style: {
          explanation_depth: "progressive_disclosure",
          tone: "direct_and_helpful",
          documentation_style: "code_tells_story_comments_explain_why",
          feedback_preference: "specific_actionable_suggestions"
        },
        workflow_patterns: {
          git_workflow: "feature_branches_with_rebase",
          code_review_focus: "architecture_and_maintainability",
          refactoring_timing: "continuous_small_improvements", 
          debugging_method: "hypothesis_driven_investigation"
        },
        collaboration_preferences: {
          decision_making: "constraint_based_not_opinion_based",
          technical_discussions: "show_dont_tell_with_examples",
          knowledge_sharing: "documentation_and_runnable_examples",
          conflict_resolution: "focus_on_user_outcomes"
        }
      },
      context_adaptations: {
        project_types: {
          startup_mvp: {
            speed_vs_quality: "speed_with_intentional_debt",
            testing_level: "critical_paths_only",
            documentation: "runnable_examples_over_comprehensive"
          },
          enterprise_system: {
            speed_vs_quality: "quality_and_maintainability_first",
            testing_level: "comprehensive_with_edge_cases",
            documentation: "comprehensive_architectural_decisions"
          },
          open_source: {
            speed_vs_quality: "balanced_with_contributor_friendly",
            testing_level: "comprehensive_with_examples",
            documentation: "extensive_contributor_onboarding"
          },
          research_prototype: {
            speed_vs_quality: "exploration_over_optimization",
            testing_level: "validation_focused",
            documentation: "experiment_rationale_and_findings"
          },
          general_development: {
            speed_vs_quality: "balanced_approach",
            testing_level: "pragmatic_coverage", 
            documentation: "clear_and_concise"
          }
        }
      }
    }

    // Analyze responses to refine personality traits
    for (const response of responses) {
      const text = response.response.toLowerCase()
      
      // Detect language preferences
      if (text.includes("rust") && text.includes("prefer")) {
        personality.personality.technical_preferences.type_systems = "strong_static_preferred"
        personality.personality.technical_preferences.error_handling = "explicit_result_types"
      } else if (text.includes("python") && text.includes("prefer")) {
        personality.personality.technical_preferences.language_selection = "productivity_and_readability"
      } else if (text.includes("go") && text.includes("prefer")) {
        personality.personality.technical_preferences.performance_philosophy = "simplicity_and_performance"
      }
      
      // Detect architecture preferences  
      if (text.includes("monolith") && text.includes("prefer")) {
        personality.personality.core_identity.architecture_philosophy = "start_simple_evolve_complexity"
      } else if (text.includes("microservice") && text.includes("prefer")) {
        personality.personality.core_identity.architecture_philosophy = "distributed_systems_first"
      }
      
      // Detect communication style
      if (text.includes("direct") || text.includes("concise")) {
        personality.personality.communication_style.tone = "direct_and_helpful"
      } else if (text.includes("detailed") || text.includes("comprehensive")) {
        personality.personality.communication_style.explanation_depth = "comprehensive_with_examples"
      }
      
      // Detect testing preferences
      if (text.includes("test") && text.includes("critical")) {
        personality.personality.technical_preferences.testing_approach = "risk_based_testing"
      } else if (text.includes("comprehensive") && text.includes("test")) {
        personality.personality.technical_preferences.testing_approach = "comprehensive_coverage"
      }
    }

    return personality
  }

  return {
    // Hook into agent configuration to inject personality
    agent: {
      async "*"(context, next) {
        const personality = await loadPersonality()
        
        if (!personality) {
          // No personality configured - continue with default behavior
          return next()
        }

        const projectType = await detectProjectType(directory)
        const personalityPrompt = generatePersonalityPrompt(personality, projectType)
        
        // Inject personality into the agent prompt
        const originalPrompt = context.agent.prompt || ""
        const enhancedPrompt = originalPrompt 
          ? `${personalityPrompt}\n\n---\n\n${originalPrompt}`
          : personalityPrompt
          
        context.agent.prompt = enhancedPrompt
        
        return next()
      }
    },

    // Add personality management tools
    tool: {
      "personality-quiz": {
        description: "Take the programming philosophy assessment to configure your global coding personality",
        async execute() {
          const existingPersonality = await loadPersonality()
          
          if (existingPersonality) {
            return `🧠 Programming personality already configured (created ${new Date(existingPersonality.meta.createdAt).toLocaleDateString()}).

Run \`/personality-show\` to view your current profile, or \`/personality-reset\` to start over.

Your personality is automatically applied to all OpenCode sessions across all repositories.`
          }
          
          const quizState = await loadQuizState()
          
          if (!quizState) {
            // Start new quiz
            const newState: QuizState = {
              currentCategory: quizCategories[0].name,
              responses: [],
              stage: "intro"
            }
            await saveQuizState(newState)
            
            return `🧠 **Programming Personality Assessment**

I'll conduct an interactive assessment to understand your authentic programming philosophy and preferences. This will create a global personality profile that applies across all your repositories.

The assessment uses **dynamic code generation** - I'll create specific examples and scenarios based on your responses, then extract your programming personality from our discussion.

**How it works:**
1. I'll present code examples for you to critique
2. Based on your responses, I'll ask follow-up questions
3. Each answer helps me understand your coding philosophy better
4. At the end, I'll extract your programming personality
5. This personality will automatically enhance all future OpenCode sessions

**Categories we'll explore:**
- Language Philosophy (error handling, type systems)
- Architecture Patterns (monoliths vs microservices)  
- Testing Strategy (unit vs integration approaches)
- Code Organization (project structure preferences)
- Performance Optimization (when and how to optimize)

Ready to begin? Type \`/personality-quiz\` again to start with the first scenario!`
          }
          
          // Continue existing quiz
          if (quizState.stage === "intro") {
            const category = quizCategories.find(c => c.name === quizState.currentCategory)!
            const question = generateQuizQuestion(category.name, category.topic, quizState.responses)
            
            quizState.stage = "questioning"
            await saveQuizState(quizState)
            
            return question
          }
          
          if (quizState.stage === "questioning") {
            return `Please respond to the current question about ${quizState.currentCategory}. 

If you'd like to see the question again, I can repeat it. Otherwise, share your detailed analysis of the code examples provided.`
          }
          
          if (quizState.stage === "complete") {
            return `Quiz already completed! Your programming personality has been saved.

Run \`/personality-show\` to view your profile.`
          }
          
          return `Quiz in progress... Current stage: ${quizState.stage}`
        }
      },

      "quiz-respond": {
        description: "Respond to the current quiz question (use when taking the personality assessment)",
        parameters: {
          type: "object",
          properties: {
            response: {
              type: "string",
              description: "Your detailed response to the current quiz question"
            }
          },
          required: ["response"]
        },
        async execute({ response }) {
          const quizState = await loadQuizState()
          
          if (!quizState) {
            return `No quiz in progress. Run \`/personality-quiz\` to start the assessment.`
          }
          
          if (quizState.stage !== "questioning" && quizState.stage !== "follow_up") {
            return `Quiz not ready for responses. Current stage: ${quizState.stage}`
          }
          
          // Save the response
          quizState.responses.push({
            category: quizState.currentCategory,
            question: `Question about ${quizCategories.find(c => c.name === quizState.currentCategory)?.topic}`,
            response: response,
            timestamp: new Date().toISOString()
          })
          
          // Check if we should ask a follow-up
          const shouldFollowUp = response.length > 200 && !quizState.followUpContext
          
          if (shouldFollowUp && quizState.stage === "questioning") {
            quizState.stage = "follow_up"
            quizState.followUpContext = response
            await saveQuizState(quizState)
            
            return `Interesting response! You mentioned several key points. Let me dig deeper:

Based on your analysis, it sounds like you value ${response.includes('performance') ? 'performance' : response.includes('readability') ? 'readability' : response.includes('maintainability') ? 'maintainability' : 'practical solutions'}.

**Follow-up question:** 
Can you walk me through a specific example from your own experience where you had to make this kind of trade-off? What was the context, what options did you consider, and what ultimately influenced your decision?

This helps me understand not just what you prefer, but *how* you make technical decisions in real situations.

Respond with \`/quiz-respond\` and your follow-up answer.`
          }
          
          // Move to next category or finish
          const currentIndex = quizCategories.findIndex(c => c.name === quizState.currentCategory)
          
          if (currentIndex < quizCategories.length - 1) {
            // Next category
            const nextCategory = quizCategories[currentIndex + 1]
            quizState.currentCategory = nextCategory.name
            quizState.stage = "questioning"
            quizState.followUpContext = undefined
            await saveQuizState(quizState)
            
            const question = generateQuizQuestion(nextCategory.name, nextCategory.topic, quizState.responses)
            
            return `Great insights! Moving to the next category...

${question}

Respond with \`/quiz-respond\` and your detailed analysis.`
          } else {
            // Quiz complete - extract personality
            quizState.stage = "complete"
            await saveQuizState(quizState)
            
            const personality = extractPersonalityFromResponses(quizState.responses)
            await savePersonality(personality)
            await clearQuizState()
            
            return `🎉 **Programming Personality Assessment Complete!**

Based on your responses, I've extracted your programming personality profile:

## Your Programming Identity
- **Approach**: ${personality.personality.core_identity.programming_approach.replace(/_/g, ' ')}
- **Architecture Philosophy**: ${personality.personality.core_identity.architecture_philosophy.replace(/_/g, ' ')}
- **Communication Style**: ${personality.personality.communication_style.tone.replace(/_/g, ' ')}
- **Decision Making**: ${personality.personality.collaboration_preferences.decision_making.replace(/_/g, ' ')}

## Context Adaptations
Your personality will automatically adapt to different project types:
- **Startup/MVP**: Speed-focused with intentional debt tracking
- **Enterprise**: Quality and maintainability emphasis
- **Open Source**: Contributor-friendly with extensive documentation
- **Research**: Exploration over optimization

**🚀 Your personality is now active!**

Every OpenCode session across all repositories will automatically apply your programming personality. No more configuration needed - just consistent, personalized coding assistance that matches your authentic style.

Use \`/personality-show\` to view your complete profile anytime.`
          }
        }
      },

      "personality-show": {
        description: "Display your current programming personality profile",
        async execute() {
          const personality = await loadPersonality()
          
          if (!personality) {
            return `No programming personality configured. 

Run \`/personality-quiz\` to take the assessment and create your global coding personality profile.`
          }

          const projectType = await detectProjectType(directory)

          return `# Your Programming Personality Profile

**Generated**: ${new Date(personality.meta.createdAt).toLocaleDateString()}
**Last Updated**: ${new Date(personality.meta.lastUpdatedAt).toLocaleDateString()}
**Currently Applied To**: ${projectType.replace(/_/g, ' ')} project

## Core Identity
- **Programming Approach**: ${personality.personality.core_identity.programming_approach.replace(/_/g, ' ')}
- **Architecture Philosophy**: ${personality.personality.core_identity.architecture_philosophy.replace(/_/g, ' ')}  
- **Code Quality Mindset**: ${personality.personality.core_identity.code_quality_mindset.replace(/_/g, ' ')}
- **Problem Solving Style**: ${personality.personality.core_identity.problem_solving_style.replace(/_/g, ' ')}

## Technical Preferences
- **Language Selection**: ${personality.personality.technical_preferences.language_selection.replace(/_/g, ' ')}
- **Type Systems**: ${personality.personality.technical_preferences.type_systems.replace(/_/g, ' ')}
- **Error Handling**: ${personality.personality.technical_preferences.error_handling.replace(/_/g, ' ')}
- **Testing Approach**: ${personality.personality.technical_preferences.testing_approach.replace(/_/g, ' ')}

## Communication Style
- **Tone**: ${personality.personality.communication_style.tone.replace(/_/g, ' ')}
- **Explanation Depth**: ${personality.personality.communication_style.explanation_depth.replace(/_/g, ' ')}
- **Documentation Style**: ${personality.personality.communication_style.documentation_style.replace(/_/g, ' ')}

## Current Project Adaptation
${Object.entries(personality.context_adaptations.project_types[projectType] || personality.context_adaptations.project_types.general_development).map(([key, value]) => 
  `- **${key.replace(/_/g, ' ')}**: ${value.replace(/_/g, ' ')}`
).join('\n')}

---

This personality is automatically applied to all OpenCode sessions across all repositories. The system detected this as a **${projectType.replace(/_/g, ' ')}** project and adapted accordingly.

Use \`/personality-reset\` to retake the assessment if your preferences have evolved.`
        }
      },

      "personality-reset": {
        description: "Reset your programming personality and retake the assessment",
        async execute() {
          try {
            await fs.unlink(personalityPath)
            await clearQuizState()
            return `🔄 **Programming personality reset!**

Your personality profile has been cleared. Run \`/personality-quiz\` to take a fresh assessment and configure a new personality profile.

All future OpenCode sessions will use default behavior until you complete the new assessment.`
          } catch {
            return `No personality profile found to reset. Run \`/personality-quiz\` to take the assessment and create your programming personality profile.`
          }
        }
      },

      "personality-status": {
        description: "Check the status of your programming personality system",
        async execute() {
          const personality = await loadPersonality()
          const quizState = await loadQuizState()
          const projectType = await detectProjectType(directory)
          
          let status = "## Programming Personality Status\n\n"
          
          if (personality) {
            status += `✅ **Personality Configured**
- Profile Version: ${personality.meta.version}
- Created: ${new Date(personality.meta.createdAt).toLocaleDateString()}
- Status: Active and applied to all OpenCode sessions

✅ **Current Project Analysis**
- Project Type: ${projectType.replace(/_/g, ' ')}
- Personality Adaptation: ${personality.context_adaptations.project_types[projectType] ? 'Applied' : 'Using general development settings'}

✅ **Global Application**
- All repositories: Personality automatically applied
- No per-repo configuration needed
- Consistent coding assistance everywhere`
          } else {
            status += `❌ **No Personality Configured**
- Status: Using default OpenCode behavior
- Recommendation: Run \`/personality-quiz\` to create your profile

📝 **Current Project Analysis**
- Project Type: ${projectType.replace(/_/g, ' ')}
- Adaptation: None (would be applied after personality configuration)`
          }
          
          if (quizState) {
            status += `\n\n🔄 **Quiz In Progress**
- Current Category: ${quizState.currentCategory}
- Stage: ${quizState.stage}
- Responses Collected: ${quizState.responses.length}
- Continue with: \`/personality-quiz\``
          }
          
          status += `\n\n**Available Commands:**
- \`/personality-quiz\` - Take or continue the assessment
- \`/personality-show\` - View your personality profile  
- \`/personality-reset\` - Reset and start over
- \`/personality-status\` - Check system status`
          
          return status
        }
      }
    }
  }
}

export default ProgrammingPersonaPlugin