# OpenCode Global Programming Persona
**Cross-repository programming personality for OpenCode AI coding agent**

## 🎯 Project Vision

Create a global programming personality system for OpenCode that:
1. Takes the dynamic programming philosophy quiz once
2. Extracts your authentic coding personality and preferences
3. Applies that personality consistently across ALL repositories
4. Overrides/enhances local AGENTS.md files with your global coding soul

## 🏗️ Implementation Strategy

### Option 1: OpenCode Fork with Global Personality (Recommended)
Fork OpenCode to add native global personality support that:
- Stores personality in `~/.opencode/personality.json`
- Injects personality context into all coding sessions
- Enhances local AGENTS.md with global preferences
- Provides personality management commands

### Option 2: OpenCode Plugin/Extension
Create a plugin that hooks into OpenCode's initialization to inject personality context before each session starts.

## 📋 Technical Architecture

### Global Personality Storage
```json
// ~/.opencode/personality.json
{
  "meta": {
    "version": "1.0.0",
    "createdAt": "2026-03-23T12:00:00.000Z",
    "lastUpdatedAt": "2026-03-23T12:00:00.000Z",
    "quizTaken": true,
    "quizVersion": "1.0.0"
  },
  "personality": {
    "core_identity": {
      "programming_approach": "pragmatic_with_standards",
      "problem_solving_style": "systematic_experimentation", 
      "architecture_philosophy": "evolutionary_design",
      "code_quality_mindset": "maintainable_and_readable"
    },
    "technical_preferences": {
      "language_selection": "right_tool_for_job",
      "type_systems": "strong_static_preferred",
      "error_handling": "explicit_result_types",
      "testing_approach": "risk_based_comprehensive",
      "performance_philosophy": "measure_then_optimize"
    },
    "communication_style": {
      "explanation_depth": "progressive_disclosure",
      "tone": "direct_and_helpful",
      "documentation_style": "code_tells_story_comments_explain_why",
      "feedback_preference": "specific_actionable_suggestions"
    },
    "workflow_patterns": {
      "git_workflow": "feature_branches_with_rebase",
      "code_review_focus": "architecture_and_maintainability", 
      "refactoring_timing": "continuous_small_improvements",
      "debugging_method": "hypothesis_driven_investigation"
    },
    "collaboration_preferences": {
      "decision_making": "constraint_based_not_opinion_based",
      "technical_discussions": "show_dont_tell_with_examples",
      "knowledge_sharing": "documentation_and_runnable_examples",
      "conflict_resolution": "focus_on_user_outcomes"
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
      },
      "open_source": {
        "speed_vs_quality": "balanced_with_contributor_friendly",
        "testing_level": "comprehensive_with_examples", 
        "documentation": "extensive_contributor_onboarding"
      },
      "research_prototype": {
        "speed_vs_quality": "exploration_over_optimization",
        "testing_level": "validation_focused",
        "documentation": "experiment_rationale_and_findings"
      }
    },
    "team_dynamics": {
      "solo_development": "future_self_as_primary_audience",
      "pair_programming": "collaborative_exploration_and_teaching",
      "code_review": "learning_opportunity_both_directions",
      "technical_mentoring": "socratic_method_with_guided_discovery"
    }
  }
}
```

### OpenCode Integration Points

#### 1. Personality Injection in Initialization
```typescript
// Modified OpenCode initialization sequence
async function initializeProject(projectPath: string) {
  // Existing OpenCode logic
  const projectContext = await analyzeProject(projectPath);
  const localAgentsConfig = await loadLocalAgentsConfig(projectPath);
  
  // NEW: Load global personality
  const globalPersona = await loadGlobalPersonality();
  
  // NEW: Enhance context with personality
  const enhancedContext = await enhanceWithPersonality(
    projectContext, 
    localAgentsConfig, 
    globalPersona
  );
  
  // Continue with enhanced context
  return createCodingSession(enhancedContext);
}
```

#### 2. Dynamic AGENTS.md Enhancement
```typescript
async function enhanceWithPersonality(
  projectContext: ProjectContext,
  localConfig: AgentsConfig,
  personality: ProgrammingPersonality
): Promise<EnhancedContext> {
  
  // Detect project type
  const projectType = detectProjectType(projectContext);
  const contextAdaptation = personality.context_adaptations.project_types[projectType];
  
  // Generate personality-enhanced AGENTS.md
  const enhancedAgentsConfig = generatePersonalityEnhancedConfig({
    projectContext,
    localConfig,
    personality,
    contextAdaptation
  });
  
  return {
    ...projectContext,
    agentsConfig: enhancedAgentsConfig,
    personalityActive: true,
    personalityVersion: personality.meta.version
  };
}

function generatePersonalityEnhancedConfig(params: {
  projectContext: ProjectContext,
  localConfig: AgentsConfig,
  personality: ProgrammingPersonality,
  contextAdaptation: ContextAdaptation
}): string {
  const { personality, contextAdaptation, localConfig } = params;
  
  return `# AGENTS.md - Enhanced with Global Programming Personality

${localConfig.content || '# Project Configuration'}

## Global Programming Personality (v${personality.meta.version})

### Core Identity: ${personality.personality.core_identity.programming_approach}

**Technical Approach:**
- Architecture: ${personality.personality.core_identity.architecture_philosophy}
- Code Quality: ${personality.personality.core_identity.code_quality_mindset}
- Problem Solving: ${personality.personality.core_identity.problem_solving_style}

**Communication Style:**
- ${personality.personality.communication_style.tone}
- ${personality.personality.communication_style.explanation_depth}
- Documentation: ${personality.personality.communication_style.documentation_style}

**Technical Preferences:**
- Language Selection: ${personality.personality.technical_preferences.language_selection}
- Type Systems: ${personality.personality.technical_preferences.type_systems}
- Error Handling: ${personality.personality.technical_preferences.error_handling}
- Testing: ${personality.personality.technical_preferences.testing_approach}

**Project Context Adaptation:**
${contextAdaptation.speed_vs_quality === 'speed_with_intentional_debt' 
  ? '- Prioritize speed with intentional technical debt tracking'
  : '- Focus on maintainable, production-ready solutions'}
${contextAdaptation.testing_level === 'critical_paths_only' 
  ? '- Test critical user paths and edge cases'
  : '- Comprehensive testing with edge case coverage'}
${contextAdaptation.documentation === 'runnable_examples_over_comprehensive'
  ? '- Provide runnable examples over comprehensive documentation'
  : '- Create comprehensive documentation and architectural decisions'}

**Decision Making Pattern:**
${personality.personality.collaboration_preferences.decision_making === 'constraint_based_not_opinion_based'
  ? `1. Understand real constraints and requirements
2. Consider multiple approaches with concrete examples
3. Evaluate tradeoffs explicitly based on project context
4. Choose based on evidence, not opinions
5. Ship and learn from real usage`
  : 'Collaborative consensus-building with stakeholder input'}

Generated from global programming personality on ${new Date().toISOString()}
`;
}
```

### 3. Personality Management Commands

#### Add new OpenCode commands for personality management:
```typescript
// New OpenCode commands
export const personalityCommands = [
  {
    name: '/personality',
    description: 'Manage your global programming personality',
    subcommands: [
      {
        name: 'quiz',
        description: 'Take the programming philosophy assessment',
        handler: async (context: OpenCodeContext) => {
          await startPersonalityQuiz(context);
        }
      },
      {
        name: 'show', 
        description: 'Display current personality profile',
        handler: async (context: OpenCodeContext) => {
          const personality = await loadGlobalPersonality();
          displayPersonalityProfile(personality, context);
        }
      },
      {
        name: 'update',
        description: 'Update specific personality traits',
        handler: async (context: OpenCodeContext) => {
          await updatePersonalityTrait(context);
        }
      },
      {
        name: 'reset',
        description: 'Reset personality and retake quiz',
        handler: async (context: OpenCodeContext) => {
          await resetPersonality(context);
        }
      }
    ]
  }
];
```

### 4. Integrated Quiz Experience
```typescript
async function startPersonalityQuiz(context: OpenCodeContext): Promise<void> {
  context.showMessage("🧠 Starting Programming Personality Assessment");
  context.showMessage("I'll generate code examples and scenarios based on your responses...");
  
  // Launch embedded quiz using our agent-driven system
  const quizSession = new ProgrammingPersonalityQuiz({
    mode: 'interactive',
    context: 'opencode_integration',
    adaptToResponses: true
  });
  
  // Run the dynamic quiz
  const results = await quizSession.conductAssessment(context);
  
  // Extract personality from results
  const personality = await extractPersonalityFromResults(results);
  
  // Save global personality
  await saveGlobalPersonality(personality);
  
  // Apply to current session
  await context.session.injectPersonality(personality);
  
  context.showSuccess("✅ Global programming personality configured!");
  context.showMessage("This will now apply to all OpenCode sessions across all repositories.");
  context.showMessage("Use '/personality show' to review your settings anytime.");
}
```

### 5. Project Type Detection
```typescript
function detectProjectType(projectContext: ProjectContext): ProjectType {
  const { packageJson, codebase, gitHistory } = projectContext;
  
  // Startup/MVP indicators
  if (hasMinimalDependencies(packageJson) && 
      hasRapidCommitHistory(gitHistory) &&
      hasTODOComments(codebase)) {
    return 'startup_mvp';
  }
  
  // Enterprise indicators  
  if (hasExtensiveTesting(codebase) &&
      hasArchitecturalDocumentation(projectContext) &&
      hasSlowCarefulCommits(gitHistory)) {
    return 'enterprise_system';
  }
  
  // Open source indicators
  if (hasContributingGuides(projectContext) &&
      hasExtensiveREADME(projectContext) &&
      hasIssueTemplates(projectContext)) {
    return 'open_source';
  }
  
  // Research prototype indicators
  if (hasExperimentalDependencies(packageJson) &&
      hasNotebookFiles(codebase) &&
      hasDataFiles(projectContext)) {
    return 'research_prototype';
  }
  
  return 'general_development';
}
```

## 🚀 Implementation Plan

### Phase 1: Core Integration (Week 1)
- Fork OpenCode repository
- Add global personality storage system
- Implement personality injection into session initialization
- Create basic personality management commands

### Phase 2: Quiz Integration (Week 2)
- Integrate the dynamic programming philosophy quiz
- Implement personality extraction from quiz results
- Create personality profile generation and storage
- Add personality display and management UI

### Phase 3: Context Adaptation (Week 3)
- Implement project type detection
- Add context-aware personality adaptation
- Enhance AGENTS.md generation with personality context
- Test across different project types

### Phase 4: Polish & Distribution (Week 4)
- Add comprehensive documentation
- Create migration guide for existing OpenCode users
- Submit pull request to main OpenCode repository
- Create standalone distribution if needed

## 💡 Key Benefits

### For Individual Developers
- **Consistent coding assistance** across ALL projects automatically
- **No more AGENTS.md configuration** in every repository
- **Authentic programming personality** that matches your actual style
- **Context-aware adaptation** to different project types

### For Teams
- **Shared team personality profiles** for consistent coding patterns
- **Individual personality preservation** within team standards
- **Reduced onboarding time** for new projects
- **Consistent code review patterns** across team members

### For OpenCode Ecosystem
- **Differentiation** from other AI coding tools
- **Enhanced user experience** without configuration overhead
- **Deeper personalization** that evolves with developers
- **Community contribution** to open source AI tooling

## 🎯 Usage Examples

### Initial Setup
```bash
# Take the personality quiz once
opencode
/personality quiz
# Interactive quiz generates personality profile

# Now every OpenCode session uses your personality
cd any-project && opencode
# Your programming soul is active immediately
```

### Personality Management
```bash
# View current personality
/personality show

# Update specific traits
/personality update testing-approach comprehensive

# Reset and retake quiz  
/personality reset
```

### Context Awareness
- **Startup repo**: Suggests pragmatic solutions with intentional tech debt tracking
- **Enterprise codebase**: Emphasizes maintainability, testing, and documentation
- **Open source project**: Focuses on contributor experience and clear examples
- **Research prototype**: Prioritizes exploration and experimental approaches

This would make OpenCode the **first AI coding agent with persistent, authentic programming personality** that travels with you across all repositories while adapting intelligently to different contexts!

Ready to start building this? The OpenCode codebase is open source, so we can fork it and implement this personality system directly.