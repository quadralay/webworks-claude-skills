# Quick Guide: Job File Creation Workflow Pattern

Condensed actionable patterns for implementing the AutoMap .waj generation workflow.

## The 6-Phase Pattern

```
Parse → Configure → Collect → Build → Preview → Generate
```

## Phase 1: Parse & Discover

**What:** Get and validate the Stationery file, extract available options

**Pattern:**
```
1. Prompt: "Stationery (.wxsp) path:"
2. Validate: File exists, correct extension
3. Parse: Extract formats, conditions, variables
4. Display: "Found N formats: [list]"
5. Store: Parsed data for later use
```

**Error handling:**
- File not found → Re-prompt
- Parse error → Report error, ask to continue manually or abort

## Phase 2: Configure Job Basics

**What:** Get job-level settings

**Pattern:**
```
1. Prompt: "Job name:" (default: based on filename)
2. Validate: Alphanumeric, no spaces
3. Confirm: Display reference to Stationery
```

## Phase 3: Collect Source Documents (Iterative)

**What:** Build hierarchical document structure

**Pattern:**
```
Loop (groups):
  Prompt: "Group name:"
  Loop (documents):
    Prompt: "Document path:" (support relative paths)
    Validate: File exists
    Confirm: "Add another document?" (y/n)
  Confirm: "Add another group?" (y/n)
```

**Display pattern:**
```
Group: "Book"
  ├─ Source\en\topic.md ✓
  ├─ Source\en\chapter1.md ✓
  └─ [Add another? y/n]
```

## Phase 4: Build Targets (Iterative)

**What:** Configure each build target

**Pattern:**
```
Loop (targets):
  Display: Available formats from Stationery
  Select: Format [1-N]
  Prompt: Target name (default: format name)
  Prompt: Build this target? (default: True)
  Prompt: Deploy target name (default: empty)
  Prompt: Clean output before build? (default: False)

  Confirm: "Override conditions?" (y/n)
    If yes:
      Display: Available conditions with defaults
      For each condition:
        Prompt: "Override [name]? Current: [value] (y/n/skip)"

  Confirm: "Set variables?" (y/n)
    If yes:
      Display: Available variables
      For each variable:
        Prompt: "[name] (default: [current]):"

  Confirm: "Add another target?" (y/n)
```

**Display format:**
```
Available Formats:
  1. WebWorks Reverb 2.0 (Application)
  2. PDF - XSL-FO (Document)
  3. Eclipse Help (Application)

Select [1-3]: 1

Target Name [WebWorks Reverb 2.0]:
Build? [Y/n]:
Deploy Target []:
Clean Output? [y/N]:

Override Conditions? [y/N]: y

Conditions from Stationery:
  OnlineOnly: True
  PrintOnly: False
  DesignerOnly: False

Override OnlineOnly? [y/n/skip]: y
  New value [True/False]: True
```

## Phase 5: Preview & Confirm

**What:** Show complete configuration before generation

**Pattern:**
```
1. Generate XML in memory (ElementTree)
2. Pretty-print XML
3. Display formatted summary
4. Confirm action
```

**Display format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Job File Preview: en.waj
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Job Name: en
Stationery: C:\path\to\stationery.wxsp

Source Documents (2 groups, 4 documents):
  Group "Book":
    • Source\en\topic.md
    • Source\en\chapter1.md
  Group "Reference":
    • ..\shared\api-reference.md
    • ..\shared\glossary.md

Targets (1):
  1. WebWorks Reverb 2.0
     Build: True
     Deploy: ""
     Clean Output: False
     Settings:
       • locale: en
     Conditions:
       • OnlineOnly: True
       • PrintOnly: False

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Generated XML (first 20 lines):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<?xml version="1.0" encoding="utf-8"?>
<Job name="en" version="1.0">
  <Project path="C:\path\to\stationery.wxsp" />
  <Files>
    <Group name="Book">
      <Document path="Source\en\topic.md" />
      ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
  (y) Generate file
  (e) Edit configuration
  (p) Show full XML preview
  (c) Cancel

Choice:
```

## Phase 6: Generate & Verify

**What:** Write file and confirm success

**Pattern:**
```
1. Write XML to file
2. Validate file can be re-parsed
3. Display success message with path
4. Optionally: Show next steps
```

**Display format:**
```
✓ Created automap-en.waj (2.1 KB)

Next steps:
  1. Review the file: code automap-en.waj
  2. Build the job: ./automap-wrapper.sh automap-en.waj
  3. Validate output: Check build logs

To edit this job later, use AutoMap Administrator.
```

## Validation Strategy

**Validate at each step, not at the end:**

| Phase | Validation |
|-------|-----------|
| Stationery path | File exists, .wxsp extension |
| Job name | Alphanumeric, no spaces, not empty |
| Document paths | Files exist (warn if not) |
| Format selection | In range [1-N] |
| Condition values | True/False only |
| Variable values | Non-empty for required vars |
| Final XML | Well-formed, parseable |

## Error Recovery Patterns

### Recoverable (Re-prompt)
```python
while True:
    value = prompt("Enter value:")
    if validate(value):
        break
    else:
        print(f"Error: {reason}. Try again.")
```

### Cancellable (Allow escape)
```python
value = prompt("Enter value (or 'cancel'):")
if value.lower() == 'cancel':
    if confirm("Abort workflow?"):
        exit()
```

### Edit-After-Preview
```python
action = prompt("(y/e/c):")
if action == 'e':
    section = select(["Job name", "Documents", "Targets"])
    # Jump back to that phase
```

## User Interaction Principles

From `user-interaction-patterns.md`:

1. **Acknowledge first**: If something doesn't exist, say so clearly
2. **Provide context**: Show what does exist
3. **Clarify ambiguity**: Ask when intent is unclear
4. **Never assume creation**: Always confirm before creating
5. **Distinguish query vs. creation**: Use verb analysis

**For job file workflow:**

```
User: "Create job file"
→ Imperative → Start wizard

User: "Show job file structure"
→ Interrogative → Display docs

User: "Generate job file"
→ Ambiguous → Ask: "Do you want to (1) create new or (2) view docs?"
```

## XML Generation Best Practices

**DO:**
- Use `xml.etree.ElementTree` to build DOM
- Use `xml.dom.minidom.toprettyxml()` for display
- Validate structure before writing
- Escape special characters automatically (ElementTree does this)

**DON'T:**
- Use string concatenation for XML
- Forget to set encoding="utf-8"
- Skip validation of generated XML

**Code pattern:**
```python
import xml.etree.ElementTree as ET
from xml.dom import minidom

# Build
root = ET.Element("Job", name=job_name, version="1.0")
project = ET.SubElement(root, "Project", path=stationery_path)
files = ET.SubElement(root, "Files")

for group in groups:
    group_elem = ET.SubElement(files, "Group", name=group['name'])
    for doc in group['documents']:
        ET.SubElement(group_elem, "Document", path=doc)

# Validate
tree = ET.ElementTree(root)
xml_str = ET.tostring(root, encoding='unicode')
ET.fromstring(xml_str)  # Will raise if invalid

# Display
pretty = minidom.parseString(xml_str).toprettyxml(indent="  ")
print(pretty)

# Write
tree.write(output_path, encoding='utf-8', xml_declaration=True)
```

## Python Library Recommendations

**For this workflow:**

1. **Typer**: Simple prompts with validation
   ```python
   import typer
   name = typer.prompt("Job name", default="job")
   if typer.confirm("Continue?"):
       ...
   ```

2. **PathLib**: Path validation
   ```python
   from pathlib import Path
   path = Path(input("Path: "))
   if path.exists():
       ...
   ```

3. **ElementTree**: XML generation
   ```python
   import xml.etree.ElementTree as ET
   root = ET.Element("Job")
   ```

**For more complex wizards (future):**

4. **PyInquirer**: Rich interactive prompts
   ```python
   from PyInquirer import prompt
   answers = prompt([
       {
           'type': 'list',
           'name': 'format',
           'message': 'Select format:',
           'choices': format_list
       }
   ])
   ```

## Progressive Disclosure Template

**Don't ask everything at once. Reveal details as needed:**

```
Level 1: Essential
  - Stationery path
  - Job name

Level 2: Core content
  - Source documents (minimal: 1 group, 1 doc)

Level 3: Build configuration
  - Targets (minimal: 1 target with defaults)

Level 4: Advanced (only if requested)
  - Condition overrides
  - Variable customization
  - Merge settings

Level 5: Confirmation
  - Preview
  - Generate
```

**Ask:**
- "Configure advanced options?" (y/n)
- "Override default conditions?" (y/n)
- "Set custom variables?" (y/n)

**Don't force users through every option if they want defaults.**

## Summary Checklist

For a successful interactive workflow:

- [ ] Parse source files first (Stationery)
- [ ] Present parsed options dynamically
- [ ] Collect information iteratively (groups, targets)
- [ ] Validate at each step
- [ ] Allow adding multiple items easily
- [ ] Show clear defaults
- [ ] Preview complete configuration
- [ ] Confirm before writing files
- [ ] Handle errors gracefully
- [ ] Allow editing after preview
- [ ] Use proper XML generation (ElementTree)
- [ ] Display success with next steps
- [ ] Follow user-interaction-patterns.md principles

---

**Quick Reference:** See `interactive-workflow-research.md` for detailed research and sources.
