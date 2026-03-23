# OpenClaw Programming Persona Plugin
**Global coding personality that persists across all repositories**

## 🎯 Project Vision

Create a global "programming soul" for OpenClaw that learns your coding preferences once through the dynamic quiz, then applies that personality consistently across ALL codebases - no more per-repo AGENTS.md configuration.

## 🏗️ Implementation Approach

### Option 1: Plugin Architecture (Recommended)
Leverage OpenClaw's plugin SDK to create a personality extension that:
- Intercepts coding session initialization
- Injects global personality preferences
- Overrides local AGENTS.md/SOUL.md when present

### Option 2: Core Fork
Fork OpenClaw to add native personality support:
- Add global personality config to `~/.openclaw/openclaw.json`
- Modify agent initialization to load global persona
- Create onboarding flow for personality detection

## 🧠 Technical Design

### Global Personality Storage
```json
// ~/.openclaw/programming-persona.json
{
  "meta": {
    "version": "1.0.0",
    "createdAt": "2026-03-22T19:00:00.000Z",
    "lastUpdatedAt": "2026-03-22T19:00:00.000Z",
    "quizVersion": "1.0.0"
  },
  "personality": {
    "core_philosophy": {
      "code_quality_approach": "pragmatic_with_standards",
      "architecture_preference": "evolutionary_design",
      "testing_philosophy": "risk_based_testing",
      "documentation_style": "code_tells_story_comments_explain_why"
    },
    "language_preferences": {
      "type_system": "strong_static_preferred",
      "performance_vs_readability": "readability_first_optimize_when_needed",
      "functional_vs_oop": "functional_patterns_oop_when_appropriate",
      "error_handling": "explicit_error_types_preferred"
    },
    "workflow_patterns": {
      "git_workflow": "feature_branches_with_rebase",
      "code_review_focus": "architecture_and_maintainability",
      "refactoring_approach": "continuous_small_improvements",
      "debugging_style": "systematic_hypothesis_testing"
    },
    "collaboration_style": {
      "technical_discussions": "constraint_based_not_opinion_based",
      "decision_making": "data_driven_with_clear_tradeoffs",
      "knowledge_sharing": "documentation_and_examples",
      "conflict_resolution": "focus_on_user_outcomes"
    },
    "expression_style": {
      "communication_tone": "direct_and_helpful",
      "explanation_depth": "context_aware_progressive_disclosure",
      "code_comments": "why_not_what",
      "variable_naming": "intention_revealing_names"
    }
  },
  "context_awareness": {
    "project_patterns": {
      "startup_mvp": "speed_over_perfection",
      "enterprise_system": "maintainability_and_testing",
      "open_source": "documentation_and_contributor_friendly",
      "research_prototype": "exploration_over_optimization"
    },
    "team_dynamics": {
      "solo_development": "future_self_as_teammate",
      "pair_programming": "collaborative_exploration",
      "code_review": "teaching_and_learning_opportunity",
      "architecture_decisions": "consensus_building_with_facts"
    }
  }
}
```

### Plugin Implementation
```typescript
// openclaw-programming-persona/src/index.ts
export const programmingPersonaPlugin: OpenClawPlugin = {
  name: 'programming-persona',
  version: '1.0.0',
  description: 'Global programming personality for consistent coding assistance',
  
  async onAgentSessionStart(ctx: PluginContext) {
    const persona = await loadGlobalPersona(ctx.api.runtime);
    const sessionContext = await ctx.api.runtime.session.getContext();
    
    // Inject personality into session context
    await ctx.api.runtime.session.updateContext({
      ...sessionContext,
      globalPersona: persona,
      personalityActive: true
    });
    
    // Override any local AGENTS.md/SOUL.md with global personality
    if (persona.meta.overrideLocal) {
      await injectGlobalPersonality(ctx, persona);
    }
  },
  
  async onPromptGeneration(ctx: PluginContext, prompt: string) {
    const persona = ctx.session.globalPersona;
    if (!persona) return prompt;
    
    // Inject personality context into system prompt
    const personalityPrompt = generatePersonalityPrompt(persona);
    return `${personalityPrompt}\n\n${prompt}`;
  },
  
  commands: [
    {
      name: 'persona',
      description: 'Manage global programming personality',
      subcommands: [
        {
          name: 'quiz',
          description: 'Take the programming philosophy quiz',
          handler: async (ctx) => {
            await startPersonalityQuiz(ctx);
          }
        },
        {
          name: 'show',
          description: 'Display current personality settings',
          handler: async (ctx) => {
            await showPersonality(ctx);
          }
        },
        {
          name: 'update',
          description: 'Update specific personality traits',
          handler: async (ctx) => {
            await updatePersonality(ctx);
          }
        },
        {
          name: 'reset',
          description: 'Reset personality and retake quiz',
          handler: async (ctx) => {
            await resetPersonality(ctx);
          }
        }
      ]
    }
  ]
};
```

### Dynamic Onboarding Integration
```typescript
// Quiz integration with OpenClaw's onboarding flow
async function startPersonalityQuiz(ctx: PluginContext): Promise<void> {
  const agentSession = await ctx.api.runtime.session.spawnAgent({
    task: 'Conduct programming philosophy quiz',
    agentId: 'quiz-conductor',
    mode: 'session',
    persistent: true,
    config: {
      quizVersion: '1.0.0',
      interactiveMode: true,
      personalityExtraction: true
    }
  });
  
  // Launch the dynamic quiz from our previous work
  await agentSession.send(`
Start the agent-driven programming philosophy quiz. 
Generate code examples and scenarios based on my responses.
Extract my programming personality and save to global persona storage.
`);
  
  // Wait for completion and extract results
  const results = await agentSession.waitForCompletion();
  const personality = await extractPersonalityFromQuizResults(results);
  
  // Save global personality
  await saveGlobalPersona(ctx.api.runtime, personality);
  
  console.log('✅ Global programming personality configured!');
  console.log('This will now apply to all coding sessions across all repositories.');
}
```

### Cross-Repository Personality Injection
```typescript
async function injectGlobalPersonality(
  ctx: PluginContext, 
  persona: ProgrammingPersona
): Promise<void> {
  
  // Generate dynamic SOUL.md content based on personality
  const dynamicSoul = generateSoulFromPersonality(persona);
  
  // Inject into session context (overrides local workspace files)
  await ctx.api.runtime.session.injectContext({
    type: 'personality-override',
    soul: dynamicSoul,
    agentsConfig: generateAgentsFromPersonality(persona),
    priority: 'global' // Higher priority than local files
  });
}

function generateSoulFromPersonality(persona: ProgrammingPersona): string {
  return `# SOUL.md - Your Global Programming Personality

## Core Identity: ${persona.personality.core_philosophy.code_quality_approach}

${persona.personality.expression_style.communication_tone === 'direct_and_helpful' 
  ? 'Be genuinely helpful, not performatively helpful. Skip the filler words and just help.'
  : ''}

## Technical Philosophy

**Architecture Approach:** ${persona.personality.core_philosophy.architecture_preference}
- Start simple, evolve complexity as needed
- ${persona.personality.language_preferences.functional_vs_oop === 'functional_patterns_oop_when_appropriate'
    ? 'Prefer functional patterns but use OOP when it clarifies the domain'
    : 'Use appropriate paradigm for the problem'}

**Code Quality Standards:**
- ${persona.personality.core_philosophy.documentation_style === 'code_tells_story_comments_explain_why'
    ? 'Code should tell a story - comments explain why, not what'
    : 'Comprehensive documentation approach'}
- ${persona.personality.core_philosophy.testing_philosophy === 'risk_based_testing'
    ? 'Testing strategies match risk and change frequency'
    : 'Comprehensive testing approach'}

**Decision Making Pattern:**
${persona.personality.collaboration_style.technical_discussions === 'constraint_based_not_opinion_based'
  ? `Technical decisions driven by constraints and tradeoffs, not opinions:
1. Understand the real constraints and requirements
2. Consider multiple approaches with concrete examples  
3. Evaluate tradeoffs explicitly
4. Choose based on context, not ideology
5. Ship and learn from real usage`
  : 'Collaborative consensus-building approach'}

## Expression Style

- ${persona.personality.expression_style.communication_tone}
- ${persona.personality.expression_style.explanation_depth}
- Match energy and depth to the context
- Focus on practical solutions over theoretical perfection

## Context Awareness

This personality adapts to project context:
- **Startup/MVP:** ${persona.context_awareness.project_patterns.startup_mvp || 'Move fast, validate assumptions'}
- **Enterprise:** ${persona.context_awareness.project_patterns.enterprise_system || 'Maintainability and reliability first'}  
- **Open Source:** ${persona.context_awareness.project_patterns.open_source || 'Documentation and contributor experience'}
- **Research:** ${persona.context_awareness.project_patterns.research_prototype || 'Exploration and learning focused'}

Generated from global programming personality assessment.
Updated: ${new Date().toISOString()}`;
}
```

## 🚀 Implementation Plan

### Phase 1: Plugin Foundation (Week 1)
- Create OpenClaw plugin scaffold
- Implement global personality storage
- Basic personality injection system
- Integration with existing quiz system

### Phase 2: Onboarding Integration (Week 2)  
- Integrate dynamic quiz as OpenClaw command
- Personality extraction from quiz results
- Global personality configuration flow
- Testing with sample codebases

### Phase 3: Advanced Features (Week 3)
- Context-aware personality adaptation
- Repository-specific overrides when needed
- Personality evolution based on coding patterns
- Integration with OpenClaw's existing workspace system

### Phase 4: Polish & Documentation (Week 4)
- Comprehensive documentation
- CLI help and examples
- Migration guide for existing setups
- Community feedback integration

## 💡 Key Features

### 🎯 One-Time Setup
```bash
# Initial personality configuration
openclaw persona quiz

# The quiz generates code examples based on your responses
# and extracts your authentic programming philosophy
```

### 🌍 Global Application
```bash
# Start any coding session - personality is automatically applied
openclaw code  # Your personality is active
cd /any/repo && openclaw code  # Same personality everywhere
```

### 🔧 Flexibility
```bash
# View current personality
openclaw persona show

# Update specific aspects  
openclaw persona update --testing-philosophy comprehensive

# Reset and retake quiz
openclaw persona reset
```

### 📊 Smart Context Adaptation
- Startup projects → Speed and iteration focus
- Enterprise codebases → Maintainability and testing
- Open source → Documentation and contributor experience
- Personal projects → Future-self consideration

## 🎖️ Benefits

**For Individual Developers:**
- Consistent coding assistance across all projects
- No more configuring preferences in every repo
- Authentic personality that matches your actual coding style
- Evolves as you grow and change as a developer

**For Teams:**
- Optional shared team personality profiles
- Consistent coding patterns across team members
- Reduced onboarding time for new repositories
- Preserved individual coding personality while maintaining team standards

**For OpenClaw Ecosystem:**
- Differentiated from other AI coding tools
- Deep personalization without per-repo configuration
- Enhanced user experience and retention
- Platform for advanced coding assistance features

This would make OpenClaw the first AI coding tool that truly "knows" how you like to code and applies that understanding everywhere automatically. No more generic responses or one-size-fits-all suggestions - just coding assistance that matches your authentic programming personality! 

Would you prefer the plugin approach or a core fork? The plugin approach would be less invasive and easier to maintain, but a core fork might enable deeper integration with OpenClaw's session management.