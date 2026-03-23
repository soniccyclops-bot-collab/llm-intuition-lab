# AGENTS.md Quick Deploy Guide

## 🎯 Purpose

These AGENTS.md files inject programming personality directly into your repositories to get better coding assistance from OpenCode (or any AI coding tool that reads AGENTS.md files).

## 📦 Available Personalities

### 1. **Brownfield Cleanup** (`AGENTS_brownfield.md`)
**Perfect for:** Legacy codebases, technical debt reduction, refactoring projects

**Key Features:**
- Systematic approach to improving existing code
- Risk-aware refactoring strategies  
- Incremental improvement focus
- Respect for working production systems
- Technical debt categorization and management

**Best For:** 
- Cleaning up messy legacy codebases
- Making brownfield systems more maintainable
- Reducing technical debt systematically
- Working with code you didn't write

### 2. **Enterprise Development** (`AGENTS_enterprise.md`)  
**Perfect for:** Large organizations, mission-critical systems, compliance-heavy environments

**Key Features:**
- Quality and reliability first approach
- Comprehensive testing strategies
- Security and compliance focus
- Operational excellence emphasis
- Team collaboration patterns

**Best For:**
- Financial services, healthcare, government projects
- Systems with high reliability requirements
- Large team development environments
- Compliance-heavy industries

### 3. **Startup MVP** (`AGENTS_startup.md`)
**Perfect for:** Fast-moving startups, product validation, rapid iteration

**Key Features:**
- Speed with intentional technical debt
- Learning-oriented development
- Rapid iteration and experimentation
- Minimal viable implementations
- User feedback focus

**Best For:**
- Early-stage startups building MVPs
- Product validation experiments  
- Fast-moving development teams
- Time-to-market critical projects

## 🚀 How to Deploy

### Quick Installation
```bash
# 1. Choose the right personality for your project
# 2. Copy the appropriate file to your repository root
cp AGENTS_brownfield.md /path/to/your/repo/AGENTS.md

# 3. Customize if needed (optional)
# Edit the AGENTS.md file to match your specific context

# 4. Start coding with OpenCode
cd /path/to/your/repo
opencode
# Your personality is now active!
```

### Detailed Setup

#### For Brownfield/Legacy Projects:
```bash
# Copy brownfield personality
cp AGENTS_brownfield.md /path/to/legacy-codebase/AGENTS.md

# Customize for your specific tech stack
# Edit the file to mention your specific frameworks, languages, etc.
```

#### For Enterprise Projects:
```bash  
# Copy enterprise personality
cp AGENTS_enterprise.md /path/to/enterprise-project/AGENTS.md

# Add company-specific guidelines
# Include compliance requirements, security standards, etc.
```

#### For Startup Projects:
```bash
# Copy startup personality  
cp AGENTS_startup.md /path/to/startup-repo/AGENTS.md

# Customize for your market and users
# Add specific business context and constraints
```

## 🔧 Customization Tips

### Basic Customization
```markdown
# Add this section to any AGENTS.md file:

## Project-Specific Context

**Technology Stack:**
- Primary Language: [Python/JavaScript/Java/etc.]
- Main Framework: [React/Django/Spring/etc.]  
- Database: [PostgreSQL/MongoDB/etc.]
- Infrastructure: [AWS/Azure/GCP/etc.]

**Business Context:**
- Industry: [FinTech/HealthTech/E-commerce/etc.]
- Scale: [Early stage/Growth stage/Enterprise/etc.]
- Users: [Internal tools/Consumer app/B2B SaaS/etc.]

**Current Challenges:**
- [Performance issues/Technical debt/Scaling problems/etc.]
- [Team onboarding/Code quality/Legacy integration/etc.]
```

### Advanced Customization

**For Python Projects:**
```markdown
### Python-Specific Guidelines
- Follow PEP 8 style guidelines
- Use type hints for better code documentation
- Prefer `pathlib` over `os.path` for file operations
- Use `dataclasses` or `pydantic` for structured data
- Follow existing patterns: Django/FastAPI/Flask conventions
```

**For JavaScript/TypeScript Projects:**
```markdown  
### JavaScript/TypeScript Guidelines
- Use TypeScript for better maintainability
- Follow existing ESLint and Prettier configurations
- Prefer modern async/await over callbacks
- Use functional programming patterns where appropriate
- Follow React/Vue/Angular specific best practices
```

**For Enterprise Security:**
```markdown
### Security Requirements
- All API endpoints must implement authentication
- Sensitive data must be encrypted at rest and in transit
- Follow OWASP security guidelines
- Implement proper input validation and sanitization
- Regular security reviews for all changes
```

## 📊 Impact Examples

### Before/After Suggestions

**Without Personality (Generic AI):**
```
// Generic suggestion
function processData(data) {
  // Process the data here
  return result;
}
```

**With Brownfield Personality:**
```typescript
// Brownfield-aware suggestion  
function processUserData(userData: UserData): ProcessedUserData {
  // SAFETY: Validate input since this comes from legacy API
  // that doesn't guarantee data structure consistency
  if (!userData || typeof userData.id !== 'string') {
    throw new ValidationError('Invalid user data structure');
  }
  
  // TODO: Refactor to use new UserDataProcessor once 
  // legacy migration is complete (tracked in TECH-DEBT.md)
  const result = legacyDataProcessor.process(userData);
  
  // Log for monitoring - helps track migration progress  
  logger.info('Processed user data', { 
    userId: userData.id,
    processingTime: Date.now() - start 
  });
  
  return result;
}
```

**With Startup Personality:**
```typescript
// Startup MVP-focused suggestion
async function processUserSignup(userData: SignupData): Promise<User> {
  // Quick implementation - validate core fields only
  // TODO: Add comprehensive validation once we understand 
  // user signup patterns better
  const user = await User.create({
    email: userData.email,
    name: userData.name
  });
  
  // Track signup for product metrics
  analytics.track('user_signup', { userId: user.id });
  
  return user;
}
```

## 🎯 Best Practices

### 1. **Match Your Context**
- Brownfield: Use for legacy systems and technical debt reduction
- Enterprise: Use for mission-critical, compliance-heavy projects  
- Startup: Use for rapid iteration and product validation

### 2. **Customize for Your Stack**
- Add specific technology guidelines
- Include team conventions and standards
- Reference existing patterns in your codebase

### 3. **Keep It Updated**  
- Evolve the AGENTS.md as your project matures
- Update constraints and priorities as business needs change
- Remove outdated guidelines that no longer apply

### 4. **Team Alignment**
- Review AGENTS.md with your team
- Make sure everyone understands the approach
- Update based on team feedback and experience

## 🚀 Immediate Benefits

**Better Code Suggestions:**
- Context-aware recommendations that fit your project type
- Appropriate balance of speed vs. quality for your situation
- Relevant examples and patterns for your technology stack

**Improved Decision Making:**
- Clear decision-making frameworks for technical choices
- Explicit trade-off analysis based on your constraints
- Risk-aware suggestions that match your project's needs

**Enhanced Team Communication:**
- Shared vocabulary for technical discussions
- Clear guidelines for code reviews and architecture decisions
- Consistent approach across team members

## 📁 File Structure

After deployment:
```
your-repository/
├── AGENTS.md                    # Your chosen personality
├── src/
├── tests/
└── ...
```

The AGENTS.md file will be automatically picked up by OpenCode and applied to all coding sessions in that repository.

---

**Ready to improve your brownfield codebases immediately!** Choose the personality that matches your context and start getting better coding assistance right away.