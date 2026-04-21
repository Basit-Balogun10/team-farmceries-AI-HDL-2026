# AI-HDL Submission Guidelines

This directory contains templates and guidelines for submitting your challenge solutions to AI-HDL 2025-2026.

## 📋 Submission Overview

Each challenge submission must include:
- **Design files** (Verilog source code)
- **AI interaction logs** (complete conversation records)
- **Verification results** (simulation and FPGA testing)
- **Documentation** (design methodology and team report)
- **Submission form** (completed template)

## 📁 Required Directory Structure

Your submission must follow this exact structure:

```
team-name-challenge-X/
├── README.md                    # Team submission summary
├── submission-form.md           # Completed submission form
├── src/                        # Source code
│   ├── top_module.v            # Main design module
│   ├── sub_module1.v           # Supporting modules
│   ├── sub_module2.v           # (as needed)
│   └── constraints.xdc         # FPGA constraints (if applicable)
├── testbench/                  # Verification files
│   ├── tb_main.v              # Primary testbench
│   ├── tb_custom.v            # Custom test cases (if any)
│   └── test_vectors/          # Input/output test data
├── ai_logs/                   # AI interaction records
│   ├── design_generation.md   # Main design conversations
│   ├── optimization.md        # Optimization discussions
│   ├── debugging.md           # Problem-solving sessions
│   └── raw_logs/             # Complete conversation exports
├── results/                   # Testing and implementation results
│   ├── simulation/           # Simulation outputs
│   ├── synthesis/            # Synthesis reports
│   ├── fpga/                # FPGA implementation results
│   └── timing/              # Timing analysis
├── docs/                     # Documentation
│   ├── design_methodology.md # Your design approach
│   ├── ai_strategy.md        # How you used AI tools
│   ├── challenges_faced.md   # Problems and solutions
│   └── lessons_learned.md    # Key insights and takeaways
└── media/                    # Supporting materials
    ├── diagrams/             # Block diagrams, flowcharts
    ├── screenshots/          # Tool outputs, waveforms
    └── videos/              # Demo videos (optional)
```

## 📝 Submission Templates

### 1. Team README Template
Use this template for your main `README.md`:

```markdown
# [Team Name] - Challenge [X] Submission

## Team Information
- **Team Name**: [Your team name]
- **Institution**: [Your university/college]
- **Division**: [Lower/Upper]
- **Team Members**: 
  - [Name 1] - [Role] - [Email]
  - [Name 2] - [Role] - [Email]
  - [Name 3] - [Role] - [Email]
- **Mentor**: [Mentor name and contact]

## Challenge Summary
Brief description of what you implemented and your approach.

## Key Features
- Feature 1: Description
- Feature 2: Description
- Feature 3: Description

## AI Tools Used
- Primary LLM: [ChatGPT-4, Claude, etc.]
- Additional tools: [Any other AI tools]
- Total AI interactions: [Approximate number]

## Results Summary
- **Functionality**: [Pass/Fail with details]
- **FPGA Implementation**: [Success/Failure]
- **Resource Usage**: [LUTs, FFs, DSPs used]
- **Timing**: [Max frequency achieved]

## Innovation Highlights
What makes your solution unique or creative.

## Team Reflection
Key learnings and insights from this challenge.
```

### 2. Submission Form Template
Complete this form in `submission-form.md`:

```markdown
# AI-HDL Challenge [X] Submission Form

## Basic Information
- **Submission Date**: [YYYY-MM-DD]
- **Challenge Number**: [1/2/3]
- **Team Name**: [Exact team name]
- **Team ID**: [Assigned during registration]

## Team Members
| Name | Role | Email | Contribution % |
|------|------|-------|----------------|
| [Name] | [Role] | [Email] | [%] |
| [Name] | [Role] | [Email] | [%] |
| [Name] | [Role] | [Email] | [%] |

## Design Specifications Met
- [ ] All required functionality implemented
- [ ] FPGA implementation successful
- [ ] Timing requirements met
- [ ] Resource constraints satisfied
- [ ] All test cases pass

## AI Tool Usage Declaration
- **Primary AI Tool**: [Tool name and version]
- **Total Conversation Sessions**: [Number]
- **Estimated AI-Generated Code %**: [Percentage]
- **Manual Modifications Made**: [Yes/No - describe if yes]

## Special Considerations
- **Bonus Features Implemented**: [List any]
- **Known Issues**: [Any limitations or bugs]
- **Future Improvements**: [What would you do differently]

## Verification Checklist
- [ ] All source files compile without errors
- [ ] Testbenches run successfully
- [ ] FPGA implementation verified on hardware
- [ ] AI interaction logs are complete
- [ ] Documentation is thorough and clear

## Team Statement
We certify that this submission represents our original work, completed according to AI-HDL rules and academic integrity guidelines. All AI interactions have been logged and submitted.

**Team Representative**: [Name and signature]
**Date**: [YYYY-MM-DD]
```

## 🤖 AI Interaction Logging Requirements

### What to Log
You must log **ALL** AI interactions, including:
- Initial design prompts and responses
- Iterative refinements and modifications
- Debugging conversations
- Optimization discussions
- Code explanation requests
- Any AI-assisted documentation

### Logging Format Options

#### Option 1: Markdown Format (Recommended)
```markdown
# AI Conversation Log - [Date/Session]

## Conversation 1: Initial Design
**Timestamp**: 2025-11-01 10:30:00
**Tool**: ChatGPT-4
**Purpose**: Generate basic module structure

**Prompt**:
```
Create a Verilog module for a 16-bit calculator that can perform addition, subtraction, multiplication, and division. Include proper input/output declarations and basic structure.
```

**Response**:
```verilog
module calculator (
    input wire clk,
    input wire rst,
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [1:0] operation,
    output reg [15:0] result,
    output reg valid
);
    // Implementation here...
endmodule
```

**Follow-up Actions**: Modified to add overflow detection
```

#### Option 2: JSON Format
```json
{
    "timestamp": "2025-11-01T10:30:00Z",
    "tool": "ChatGPT-4",
    "session_id": "session_001",
    "conversation": [
        {
            "role": "user",
            "content": "Create a Verilog module for..."
        },
        {
            "role": "assistant", 
            "content": "module calculator (...)"
        }
    ],
    "metadata": {
        "purpose": "Initial design generation",
        "outcome": "Successful base implementation"
    }
}
```

### Logging Tools
Use our provided logging utilities:
```bash
# In Docker container
python3 ~/tools/python/aihdl/logger.py

# Or use the interactive logging notebook
jupyter notebook ~/tools/notebooks/ai_logging.ipynb
```

## 🧪 Verification Requirements

### Simulation Testing
- **Compile successfully** with no errors or warnings
- **Pass all provided test cases** in the challenge specification
- **Include custom test cases** that demonstrate thorough verification
- **Generate waveform files** for key test scenarios

### FPGA Implementation
- **Synthesize successfully** within resource constraints
- **Meet timing requirements** at specified clock frequency
- **Demonstrate functionality** on actual hardware
- **Document implementation process** with screenshots/videos

### Test Coverage
Your testbenches should verify:
- **Basic functionality** - all required operations work
- **Edge cases** - boundary conditions and special values
- **Error conditions** - invalid inputs and error handling
- **Timing** - setup/hold times and clock domain crossing
- **Reset behavior** - proper initialization and reset response

## 📊 Documentation Requirements

### Design Methodology Document
Explain your design process:
```markdown
# Design Methodology

## Initial Approach
How did you start? What was your overall strategy?

## AI Integration Strategy
How did you plan to use AI tools? What was your prompting strategy?

## Design Evolution
How did your design change throughout the process?

## Key Decisions
What were the major design decisions and trade-offs?

## Verification Strategy
How did you ensure your design was correct?
```

### AI Strategy Document
Detail your AI usage:
```markdown
# AI Strategy and Usage

## Tool Selection
Why did you choose specific AI tools?

## Prompting Techniques
What prompting strategies worked best?

## Iteration Process
How did you refine AI-generated code?

## AI Limitations Encountered
Where did AI fall short? How did you overcome limitations?

## Learning from AI
What did AI teach you about hardware design?
```

## 📤 Submission Process

### Step 1: Prepare Your Submission
1. **Organize files** according to the required structure
2. **Complete all templates** with accurate information
3. **Verify all files** are included and functional
4. **Test your submission** in a clean environment

### Step 2: Create Submission Package
```bash
# Create a compressed archive
tar -czf team-name-challenge-X.tar.gz team-name-challenge-X/

# Or use zip
zip -r team-name-challenge-X.zip team-name-challenge-X/
```

### Step 3: Submit via Portal
1. **Upload to submission portal**: [Link will be provided]
2. **Fill out online form**: Basic team and submission info
3. **Verify upload**: Ensure all files are included
4. **Confirm submission**: You'll receive a confirmation email

### Step 4: Backup Submission
Also submit via alternative method:
- **Email backup**: Send to aihdl-submissions@arizona.edu
- **Discord notification**: Post in #submissions channel
- **Git repository**: Push to your team's private repo (if provided)

## ⏰ Submission Deadlines

### Important Dates
- **Challenge Release**: First day of month
- **Milestone Review**: Mid-month (optional)
- **Final Submission**: Last day of challenge period
- **Late Submission**: 48-hour grace period with penalty

### Grace Period Policy
- **First 24 hours**: 10% penalty
- **24-48 hours**: 25% penalty
- **After 48 hours**: Submission not accepted

## 🔍 Evaluation Process

### Automated Testing (Day 1)
- File structure verification
- Compilation and synthesis testing
- Basic functionality testing
- Resource usage analysis

### Manual Review (Days 2-5)
- AI interaction log review
- Documentation quality assessment
- Innovation and creativity evaluation
- Code quality and style review

### FPGA Verification (Days 3-7)
- Hardware implementation testing
- Timing analysis verification
- Resource usage confirmation
- Performance benchmarking

## ❌ Common Submission Issues

### File Structure Problems
- **Missing directories**: Ensure all required folders exist
- **Incorrect naming**: Use exact names specified in templates
- **Empty files**: All files should have meaningful content
- **Wrong file types**: Use specified formats (.v, .md, etc.)

### AI Log Issues
- **Incomplete logs**: Missing conversations or partial records
- **Unreadable format**: Use specified markdown or JSON format
- **Missing metadata**: Include timestamps, tools used, purposes
- **No raw logs**: Include complete conversation exports

### Technical Problems
- **Compilation errors**: Test all code before submission
- **Missing testbenches**: Include comprehensive verification
- **Resource violations**: Ensure design fits constraints
- **Timing failures**: Meet specified clock frequencies

## 🏆 Evaluation Criteria Reminder

### Functionality (40%)
- Correctness of implementation
- Meeting all specifications
- Successful FPGA deployment
- Comprehensive testing

### AI Integration (25%)
- Effective use of AI tools
- Quality of prompting strategies
- Complete interaction logging
- Learning from AI feedback

### Innovation (20%)
- Creative problem-solving approaches
- Novel design techniques
- Unique AI applications
- Going beyond basic requirements

### Documentation (15%)
- Clear methodology explanation
- Complete AI interaction records
- Professional presentation
- Insightful reflection and learning


