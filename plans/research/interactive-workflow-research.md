# Research: Best Practices for Interactive CLI/Skill Workflows

Research conducted on 2025-12-05 for creating AutoMap job file (.waj) generation workflow.

## Executive Summary

This research identifies best practices for creating interactive CLI/skill workflows that gather structured information from users to generate configuration files. Key findings emphasize:

1. **Progressive disclosure** over monolithic prompts
2. **Explicit confirmation** before file generation
3. **Validation at each step** rather than end-validation
4. **Clear presentation** of parsed options from existing files
5. **Dry-run/preview patterns** before committing changes

## 1. Claude Code Skill Patterns for Multi-Step Input

### Core Workflow Pattern

Based on [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices), the recommended pattern is:

```
Explore → Plan → Code → Commit
```

For interactive workflows, this translates to:

```
Parse/Discover → Present Options → Gather Input → Validate → Preview → Generate
```

### Progressive Disclosure Principle

From [Claude Agent Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/):

> "Progressive disclosure—revealing details as needed—remains central to effective skill design for complex user interactions."

**Application for .waj generation:**
- Step 1: Get Stationery path, parse it
- Step 2: Show available formats, ask user to select
- Step 3: Gather source documents (can be iterative)
- Step 4: Configure targets with overrides
- Step 5: Preview generated XML
- Step 6: Confirm and write file

### Wizard-Style Multi-Step Process

Skills should break complex tasks into discrete steps with **explicit user confirmation between phases**. This pattern works well for:
- Setup wizards
- Configuration tools
- Guided processes where users provide input at specific checkpoints

**Key principle:** Never assume. Always confirm before creating.

## 2. Gathering Hierarchical Information

### Hierarchical Question Organization

From [Inquirer.js documentation](https://www.npmjs.com/package/inquirer):

> "You can organize the question results in an object hierarchy. This is especially useful when you have a complex set of questions, or maybe want to construct the desired object structure directly from the question results."

**Pattern:** Use delimited question names (e.g., `target.name`, `target.format`) to create a tree structure for answers.

**For job file creation:**
```
job.name
job.stationeryPath
files.group[0].name
files.group[0].documents[0]
files.group[0].documents[1]
targets[0].name
targets[0].format
targets[0].conditions.OnlineOnly
targets[0].variables.ProductVersion
```

### Dynamic Question Building

> "Don't hesitate to use multiple sets of questions as the previous results can be used to dynamically build new questions whose amount is not known beforehand."

**Application:**
1. After parsing Stationery, dynamically create format selection from available formats
2. After selecting format, dynamically create condition/variable questions from format schema
3. Allow adding multiple document groups iteratively

### Iterative Collection Pattern

For collections (like document groups), use this pattern:

```
1. Gather first item
2. Ask "Add another?" (y/n)
3. If yes, goto 1
4. If no, proceed to next phase
```

## 3. Presenting Choices from Parsed Files

### Read-Process-Present Pattern

From research findings:

```
1. Parse file (Stationery .wxsp)
2. Extract available options (formats, conditions, variables)
3. Present as structured choices to user
4. Validate selection against parsed schema
```

### Display Format for Parsed Options

**Lists with context:**
```
Available formats from Stationery.wxsp:
1. WebWorks Reverb 2.0 (Application)
2. PDF - XSL-FO (Document)
3. Eclipse Help (Application)

Select format [1-3]:
```

**Hierarchical display:**
```
Format: WebWorks Reverb 2.0
Available Conditions:
  - OnlineOnly (default: True)
  - PrintOnly (default: False)
  - DesignerOnly (default: False)

Available Variables:
  - ProductVersion (current: "2024.1")
  - PublicationDate (current: "")
  - bookname (current: "")
```

### Contextual Defaults

Present current/default values from the Stationery to help users make informed decisions:
- Show default condition values
- Show available variable names with their default values
- Indicate required vs. optional settings

## 4. Validation Strategies During Input Gathering

### Validate Early, Validate Often

From [Typer documentation](https://stashsoftware.com/blog/article/mastering-pythons-typer-module-for-building-interactive-clis-80):

> "By defining function parameters with type hints, typer automatically validates input, reducing potential errors due to incorrect data types."

### Multi-Level Validation Strategy

**Level 1: Format Validation (Immediate)**
- File path exists
- File extension correct
- Numeric input is actually numeric

**Level 2: Schema Validation (Per Step)**
- Selected format exists in Stationery
- Condition names are valid
- Variable names match available variables

**Level 3: Cross-Field Validation (Before Generation)**
- Source documents exist at specified paths
- Target names are unique
- Required fields are populated

### Validation Error Handling

From [pypsi.wizard documentation](https://pythonhosted.org/pypsi/pypsi.wizard.html):

> "Each step can have validators that determine if a value is valid before proceeding to the next step."

**Error pattern:**
```
Input: [invalid value]
Error: [specific reason]
[Re-prompt for same field]
```

**Example:**
```
Enter Stationery path: C:\invalid\path.txt
Error: File not found at C:\invalid\path.txt
Enter Stationery path:
```

### Validation with User Recovery

From [CLI automation research](https://www.thegreenreport.blog/articles/interactive-cli-automation-with-python/interactive-cli-automation-with-python.html):

> "When you expect y/n but user enters the letter 'a', you throw an error and repeat. This is achieved with a while loop."

**Pattern:**
```python
while True:
    user_input = get_input()
    if validate(user_input):
        break
    else:
        print(f"Error: {validation_error}")
        # Loop continues
```

## 5. Preview/Confirmation Patterns Before File Generation

### The Dry-Run Pattern

From [Nick Janetakis: CLI Tools That Support Previews](https://nickjanetakis.com/blog/cli-tools-that-support-previews-dry-runs-or-non-destructive-actions):

> "Being able to see the output of something before it happens for real is helpful."

**Common implementations:**
- `--dry-run` flag: Show what would happen without executing
- `--preview` flag: Display generated content without writing
- `--validate-only` flag: Check validity without making changes

### Preview-Confirm-Execute Pattern

**Step 1: Generate Preview**
```
Generated configuration (preview):
-----------------------------------
[Display formatted XML or summary]
-----------------------------------
```

**Step 2: Confirm Action**
```
Write this configuration to automap-job.waj? (y/n):
```

**Step 3: Execute or Cancel**
```
If y: Write file, show success message
If n: Return to editing or abort
```

### Summary Before Generation

From CLI best practices research:

> "Before you take action, you can print out the entire configuration and ask the user to verify. If user says no, you can start over again."

**For job file creation:**
```
Summary of Job Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Job Name: en
Stationery: C:\path\to\stationery.wxsp

Source Documents:
  Group "Book":
    - Source\en\topic.md
    - Source\en\chapter1.md
  Group "Reference":
    - ..\shared\api-reference.md

Targets:
  1. WebWorks Reverb 2.0
     Build: True
     Deploy: ""
     Settings:
       - locale: en

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Proceed with generation? (y/n/edit):
```

### Edit-After-Preview Pattern

Allow users to:
1. Preview configuration
2. Edit specific sections
3. Re-preview
4. Confirm when satisfied

**Example:**
```
Preview: [show config]
Options:
  (y) Generate file
  (e) Edit configuration
  (c) Cancel

Choice: e

What would you like to edit?
  1. Job name
  2. Source documents
  3. Targets
  4. Cancel edit

Choice: 2
[Return to source document gathering...]
```

## 6. User Interaction Patterns from Existing Skills

### Pattern from user-interaction-patterns.md

The ePublisher skills follow this decision tree:

```
User Request
    ├─ Clear interrogative? (What, Where, Show, List)
    │   └─ Provide information ONLY
    │
    ├─ Clear imperative? (Add, Create, Make)
    │   └─ Proceed with creation (confirm parameters)
    │
    ├─ Ambiguous verb? (generate, get, provide)
    │   ├─ Item exists?
    │   │   └─ Show/provide it
    │   └─ Item doesn't exist?
    │       └─ Acknowledge + Ask intent
    │
    └─ Item doesn't exist (any case)
        ├─ Acknowledge non-existence
        ├─ Show what DOES exist
        └─ Offer creation (if applicable)
```

**Key principles:**
1. Acknowledge first - If something doesn't exist, say so clearly
2. Provide context - Show what does exist
3. Clarify ambiguity - Ask when intent is unclear
4. Never assume creation - Always confirm before creating
5. Distinguish query vs. creation - Use verb analysis and context

### Application to Job File Workflow

**User:** "Create a job file"
- Clear imperative → Proceed with creation
- Gather parameters interactively

**User:** "Show me job file options"
- Clear interrogative → Display available settings/formats from Stationery
- Don't create anything

**User:** "Generate a job file"
- Ambiguous → Clarify intent:
  ```
  Do you want to:
  1. Create a new job file (interactive setup)
  2. Show the structure of a job file (documentation)
  3. Parse an existing job file (read-only)
  ```

## 7. XML Generation Best Practices

### Avoid String Concatenation

From [Python XML generation research](https://stackoverflow.com/questions/3057582/python-configuration-file-generator):

> "You should avoid generating XML by plain string concatenation because you can easily run into encoding problems."

**Recommended approach:**
- Use `xml.etree.ElementTree` (Python)
- Use `xml.dom.minidom` for pretty printing
- Build DOM structure, then serialize

### Template-Based Generation

From [PowerShell XML generation](https://www.sapien.com/blog/2009/05/26/creating-xml-configuration-files-the-powershell-way/):

> "The XML is contained within a here string... Notice the placeholders like {0} and {1}. The -f operator can be used to fill in the blanks."

**For job files:**
1. Create XML template with placeholders
2. Validate structure once
3. Fill placeholders with user data
4. Validate against schema

### XML Schema Validation

From [Best Practices for Managing XML Configurations](https://www.deltaxignia.com/blog/data-management/best-practices-for-managing-xml-configurations-in-system-administration):

> "Use tools like XML validators to verify XML configurations are free of syntactical errors and conform to the defined schema or Document Type Definition (DTD)."

**For .waj generation:**
1. Generate XML using ElementTree
2. Validate against .waj schema (if available)
3. Pretty-print for human readability
4. Show preview to user
5. Write file only after confirmation

## 8. Interactive CLI Library Recommendations

### Python Options

**1. Typer (Recommended for simple workflows)**
- Type-safe validation
- Colored output
- Interactive prompts built-in
- Example: `typer.confirm("Proceed?")`, `typer.prompt("Enter name")`

**2. PyInquirer (Recommended for complex wizards)**
- Rich prompt types (list, checkbox, input, confirm)
- Built on prompt-toolkit
- Supports validation per prompt
- Hierarchical question organization

**3. Click (Industry standard)**
- Robust parameter validation
- Wide ecosystem
- Well-documented

**4. prompt-toolkit (Low-level, maximum control)**
- Build custom interactive shells
- Full control over UX
- Steeper learning curve

### JavaScript/Node.js Options (Reference)

**Inquirer.js:**
- Hierarchical configuration via dot-delimited names
- Multiple prompt types
- Used by npm init, Yeoman generators
- Pattern to emulate in Python workflows

## 9. Recommended Workflow for .waj Creation

Based on all research findings:

### Phase 1: Discovery & Validation
```
1. Prompt for Stationery path
2. Validate file exists and is .wxsp
3. Parse Stationery to extract:
   - Available formats
   - Default conditions
   - Available variables
4. Display parsing results to user
```

### Phase 2: Job Configuration
```
1. Prompt for job name (default: filename without .waj)
2. Validate name (alphanumeric, no spaces)
```

### Phase 3: Source Documents (Iterative)
```
Loop:
  1. Prompt for group name
  2. Loop for documents in group:
     a. Prompt for document path (relative or absolute)
     b. Validate path exists
     c. Ask "Add another document to this group?" (y/n)
  3. Ask "Add another group?" (y/n)
```

### Phase 4: Target Configuration (Iterative)
```
Loop:
  1. Show available formats from Stationery
  2. Prompt user to select format
  3. Prompt for target name (default: format name)
  4. Prompt for build flag (default: True)
  5. Prompt for deployTarget (default: empty)
  6. Prompt for cleanOutput (default: False)
  7. Ask "Override conditions?" (y/n)
     If yes:
       - Show available conditions with defaults
       - Allow selective override
  8. Ask "Set variables?" (y/n)
     If yes:
       - Show available variables
       - Prompt for values
  9. Ask "Add another target?" (y/n)
```

### Phase 5: Preview & Confirmation
```
1. Generate XML in memory
2. Display formatted preview
3. Show summary:
   - Job name
   - Stationery reference
   - Number of groups/documents
   - Number of targets
4. Prompt: "Proceed with generation? (y/n/edit)"
   - y: Write file
   - n: Abort
   - edit: Return to specific phase
```

### Phase 6: Generation & Verification
```
1. Write XML file to disk
2. Validate written file can be parsed
3. Report success with file path
4. Optionally: Open in text editor
```

## 10. Error Handling Patterns

### Graceful Degradation
```
Try: Parse Stationery
Catch ParseError:
  - Report specific error
  - Offer to proceed with manual format entry
  - Or abort and fix Stationery
```

### Recoverable Errors
```
If validation fails:
  1. Show specific error message
  2. Show current value (if any)
  3. Re-prompt for input
  4. Allow user to cancel workflow
```

### Unrecoverable Errors
```
If critical error (e.g., Stationery corrupted):
  1. Report error clearly
  2. Explain impact
  3. Suggest remediation
  4. Abort workflow gracefully
```

## 11. Python Implementation Sketch

```python
# Using Typer for simple prompts + custom validation

import typer
from pathlib import Path
from typing import List, Dict
import xml.etree.ElementTree as ET

def create_job_file():
    """Interactive job file creation wizard."""

    # Phase 1: Discovery
    stationery_path = get_validated_path("Enter Stationery (.wxsp) path: ")
    stationery_config = parse_stationery(stationery_path)

    typer.echo(f"Found {len(stationery_config['formats'])} formats in Stationery")

    # Phase 2: Job Config
    job_name = typer.prompt("Job name", default="job")

    # Phase 3: Source Documents
    groups = collect_source_groups()

    # Phase 4: Targets
    targets = collect_targets(stationery_config)

    # Phase 5: Preview
    xml_tree = generate_job_xml(job_name, stationery_path, groups, targets)
    preview_xml(xml_tree)

    if typer.confirm("Generate job file?"):
        output_path = f"{job_name}.waj"
        write_xml(xml_tree, output_path)
        typer.secho(f"Created {output_path}", fg=typer.colors.GREEN)
    else:
        typer.echo("Cancelled.")

def collect_source_groups() -> List[Dict]:
    """Iteratively collect source document groups."""
    groups = []

    while True:
        group_name = typer.prompt("Group name")
        documents = []

        while True:
            doc_path = get_validated_path("Document path: ")
            documents.append(str(doc_path))

            if not typer.confirm("Add another document to this group?"):
                break

        groups.append({"name": group_name, "documents": documents})

        if not typer.confirm("Add another group?"):
            break

    return groups

def preview_xml(xml_tree: ET.ElementTree):
    """Display formatted XML preview."""
    from xml.dom import minidom

    xml_str = ET.tostring(xml_tree.getroot(), encoding='unicode')
    pretty_xml = minidom.parseString(xml_str).toprettyxml(indent="  ")

    typer.echo("\n" + "="*60)
    typer.echo("PREVIEW:")
    typer.echo("="*60)
    typer.echo(pretty_xml)
    typer.echo("="*60 + "\n")

# ... more helper functions
```

## 12. Key Takeaways for AutoMap Job File Workflow

1. **Start with file parsing**: Parse Stationery first to show real options
2. **Use iterative collection**: Allow users to add multiple groups/documents/targets
3. **Validate continuously**: Don't wait until the end to validate
4. **Preview before generation**: Always show what will be created
5. **Allow editing after preview**: Don't force start-over for mistakes
6. **Use clear prompts**: Show defaults, show available options
7. **Structure hierarchically**: Group related settings together
8. **Provide context**: Explain what each setting does
9. **Generate XML properly**: Use ElementTree, not string concatenation
10. **Confirm destructive actions**: Always ask before writing files

## 13. References & Sources

### Claude Code & Skills
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Multi-step workflows
- [Claude Agent Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) - Progressive disclosure patterns
- [Common workflows - Claude Docs](https://docs.claude.com/en/docs/claude-code/common-workflows)

### Interactive CLI Patterns
- [Inquirer.js - npm](https://www.npmjs.com/package/inquirer) - Hierarchical configuration patterns
- [Mastering Python's Typer Module](https://stashsoftware.com/blog/article/mastering-pythons-typer-module-for-building-interactive-clis-80) - Type-safe prompts
- [pypsi.wizard documentation](https://pythonhosted.org/pypsi/pypsi.wizard.html) - Step validation
- [Interactive CLI Automation with Python](https://www.thegreenreport.blog/articles/interactive-cli-automation-with-python/interactive-cli-automation-with-python.html)

### Validation & Preview Patterns
- [CLI Tools That Support Previews, Dry Runs](https://nickjanetakis.com/blog/cli-tools-that-support-previews-dry-runs-or-non-destructive-actions) - Dry-run pattern
- [Command Line Interface Guidelines](https://clig.dev/) - General CLI best practices
- [How to Dry Run Linux Commands](https://itsfoss.gitlab.io/post/how-to-dry-run-or-simulate-linux-commands-without-changing-anything-in-the-system/)

### XML Generation
- [Best Practices for Managing XML Configurations](https://www.deltaxignia.com/blog/data-management/best-practices-for-managing-xml-configurations-in-system-administration) - Validation, documentation
- [Python configuration file generator - Stack Overflow](https://stackoverflow.com/questions/3057582/python-configuration-file-generator) - Avoid string concatenation
- [Creating XML Configuration Files the PowerShell Way](https://www.sapien.com/blog/2009/05/26/creating-xml-configuration-files-the-powershell-way/) - Template patterns

### Data Validation
- [Google Data Validation Tool](https://www.marktechpost.com/2021/08/19/google-open-sources-its-data-validation-tool-dvt-a-python-cli-tool-that-provides-an-automated-and-repeatable-solution-for-validation-across-different-environments/)
- [Structured Data Testing & Validation Tool](https://www.screamingfrog.co.uk/seo-spider/tutorials/structured-data-testing-validation/)

---

**Document Version:** 1.0
**Research Date:** 2025-12-05
**Context:** AutoMap job file (.waj) creation workflow for epublisher-automation plugin
