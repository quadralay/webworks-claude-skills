# Markdown++ Best Practices

Guidelines for effective use of Markdown++ extensions in documentation projects.

## When to Use Each Extension

### Variables

**Use variables for:**
- Product names that might change
- Version numbers updated per release
- URLs that may be environment-specific
- Repeated content across multiple documents
- Values defined in ePublisher project settings

**Avoid variables for:**
- One-time text that won't repeat
- Content that varies significantly between uses
- Complex formatted content (use includes instead)

**Example - Good:**
```markdown
Welcome to $product_name; version $version;.
Download from $download_url;.
```

**Example - Avoid:**
```markdown
$intro_paragraph;  <!-- Too much content in a variable -->
```

### Custom Styles

**Use styles for:**
- Consistent formatting across documents
- Semantic meaning beyond basic Markdown
- Output format-specific rendering
- Tables, code blocks, callouts that need custom treatment

**Avoid styles for:**
- Every heading and paragraph (overuse)
- Content where standard Markdown formatting suffices
- Styles that aren't defined in your Stationery

**Block vs. Inline:**
- Use **block styles** for headings, paragraphs, lists, code blocks, tables
- Use **inline styles** for emphasized text within paragraphs

**Example - Good:**
```markdown
<!--style:WarningBox-->
> **Warning:** This action cannot be undone.

This is <!--style:UIElement-->**Settings**<!--style:Normal--> button.
```

**Example - Avoid:**
```markdown
<!--style:NormalParagraph-->
This is just regular text that doesn't need a style.
```

### Custom Aliases

**Use aliases for:**
- **All important headings** to ensure stable URL endpoints
- Stable links that survive document restructuring
- Cross-document linking
- Links to non-heading elements
- Section anchors with custom names

**Avoid aliases for:**
- Temporary content
- Internal drafts

**Keep alias values unique within each file.** The validation script checks for duplicates.

**Example - Good:**
```markdown
<!--#api-authentication-->
## Authenticating with the API

Later: See [Authentication](#api-authentication) for details.
```

**Generate aliases automatically:**
```bash
python scripts/add-aliases.py document.md --levels 1,2,3
```

### Conditions

**Use conditions for:**
- Platform-specific content (Windows/Mac/Linux)
- Output format differences (web/print/PDF)
- Audience-specific content (beginner/advanced)
- Development vs. production content
- Internal vs. external documentation

**Avoid conditions for:**
- Minor text differences (use variables instead)
- Content that should always appear
- Deeply nested conditions (hard to maintain)

**Example - Good:**
```markdown
<!--condition:windows-->
Download the `.exe` installer.
<!--/condition-->

<!--condition:mac-->
Download the `.dmg` disk image.
<!--/condition-->
```

**Example - Avoid:**
```markdown
<!--condition:windows-->
Click <!--condition:windows10-->Start<!--/condition--><!--condition:windows11-->the Windows icon<!--/condition-->...
<!--/condition-->
```

### File Includes

**Use includes for:**
- Shared headers and footers
- Boilerplate legal text
- Reusable content blocks
- Modular documentation structure
- Common examples or code snippets

**Avoid includes for:**
- Very small content (inline it instead)
- Content that varies significantly per use
- Creating deeply nested include chains

**Example - Good:**
```markdown
<!--include:shared/copyright-notice.md-->
<!--include:chapters/installation.md-->
```

### Markers

**Use markers for:**
- Search keywords for Reverb output
- Document metadata (author, category)
- Content that needs special processing
- Passthrough text for output formats

**Avoid markers for:**
- Information already in document content
- Excessive keyword stuffing
- Markers that aren't processed by your output format

**Preferred format (single key-value):**
```markdown
<!--marker:Keywords="installation, setup"-->
```

**Multiple markers:**
```markdown
<!--marker:Keywords="installation" ; marker:Category="User Guide"-->
```

**JSON format (alternative for complex metadata):**
```markdown
<!--markers:{"Keywords": "installation, setup, getting started", "Category": "User Guide"}-->
```

### Multiline Tables

**Use multiline tables for:**
- Complex data requiring lists or code in cells
- Feature comparisons with detailed descriptions
- Reference tables with examples
- Content that doesn't fit in single-line cells

**Avoid multiline tables for:**
- Simple tabular data
- Tables where standard Markdown works
- Deeply nested content in cells

### Combined Commands

**Order priority:** style, multiline, marker(s), #alias

```markdown
<!-- style:ImportantHeading ; marker:Priority="high" ; #critical-section -->
## Critical Section

<!-- style:DataTable ; multiline ; #comparison-table -->
| Column | Data |
|--------|------|
```

**Avoid:** Inconsistent ordering that makes documents harder to read.

### Inline Styling for Images

**Use inline styles for:**
- Logo images requiring specific formatting
- Screenshots with consistent borders/shadows
- Icons that need size control

**Example:**
```markdown
<!--style:ScreenshotImage-->![Settings Panel](images/settings.png)

<!--style:LogoImage-->![Company Logo](images/logo.svg)
```

### Inline Styling for Links

**Place style inside link text brackets:**
```markdown
See [<!--style:ImportantLink-->**API Reference**](api.md#auth).

Visit the [<!--style:ExternalLink-->*documentation*](https://docs.example.com).
```

**Avoid:** Placing style before the entire link syntax (use inside brackets).

### Content Islands (Styled Blockquotes)

**Use content islands for:**
- Learning boxes with multiple content types
- Warning/caution callouts with lists
- Tips with code examples
- Any "block within a block" layout

**Example:**
```markdown
<!--style:BQ_Learn-->
> ## Key Concept
>
> This learning box contains:
>
> - Lists
> - Code blocks
> - Multiple paragraphs
>
> All within a styled container.
```

**Best practice:** Include a heading inside the blockquote for accessibility.

## Document Structure

### Recommended Organization

```markdown
<!--markers:{"Author": "...", "Version": "..."}-->
<!--#document-id-->

# $document_title;

<!--include:shared/header.md-->

## Introduction

Main content here...

<!--condition:advanced-->
## Advanced Topics

Advanced content...
<!--/condition-->

<!--include:shared/footer.md-->

<!--marker:Keywords="..."-->
```

### Condition Placement

**Do:** Keep conditions at natural content boundaries

```markdown
<!--condition:web-->
## Web-Only Section

Content here...
<!--/condition-->
```

**Don't:** Fragment content with many small conditions

```markdown
## Section
<!--condition:web-->Word<!--/condition--><!--condition:print-->Text<!--/condition--> here.
```

### Include Organization

Create a logical structure:

```
docs/
├── main.md              # Main document with includes
├── shared/
│   ├── header.md        # Common header
│   └── footer.md        # Common footer
├── chapters/
│   ├── intro.md         # Introduction chapter
│   └── features.md      # Features chapter
└── examples/
    └── code-samples.md  # Reusable code examples
```

## Variable Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Product names | lowercase with underscores | `$product_name;` |
| Versions | descriptive | `$version;`, `$api_version;` |
| URLs | descriptive with suffix | `$download_url;`, `$support_url;` |
| Dates | descriptive | `$release_date;`, `$last_updated;` |
| Platform-specific | platform prefix | `$windows_path;`, `$mac_path;` |

## Condition Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Output format | format name | `web`, `print`, `pdf`, `chm` |
| Platform | platform name | `windows`, `mac`, `linux` |
| Audience | audience level | `beginner`, `advanced`, `admin` |
| Environment | environment name | `production`, `development`, `staging` |
| Feature flags | feature name | `feature_x`, `beta_feature` |

## Style Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Headings | `Heading` + context | `HeadingChapter`, `HeadingSection` |
| Notes/Callouts | Box type | `NoteBox`, `WarningBox`, `TipBox` |
| Code | `Code` + type | `CodeExample`, `CodeOutput` |
| Tables | `Table` + purpose | `TableData`, `TableComparison` |
| UI Elements | `UI` + element | `UIButton`, `UIMenu` |

## Common Mistakes to Avoid

### 1. Missing Semicolons on Variables

**Wrong:**
```markdown
Welcome to $product_name, version $version.
```

**Right:**
```markdown
Welcome to $product_name;, version $version;.
```

### 2. Blank Line After Block Style

**Wrong:**
```markdown
<!--style:CustomHeading-->

# Heading
```

**Right:**
```markdown
<!--style:CustomHeading-->
# Heading
```

### 3. Space Before Inline Style Target

**Wrong:**
```markdown
This is <!--style:Emphasis--> **bold**.
```

**Right:**
```markdown
This is <!--style:Emphasis-->**bold**.
```

### 4. Forgetting to Close Conditions

**Wrong:**
```markdown
<!--condition:web-->
Web content here...
<!-- Forgot to close! -->
```

**Right:**
```markdown
<!--condition:web-->
Web content here...
<!--/condition-->
```

### 5. Invalid JSON in Markers

**Wrong:**
```markdown
<!--markers:{Keywords: "test"}--> <!-- Missing quotes on key -->
```

**Right:**
```markdown
<!--markers:{"Keywords": "test"}-->
```

### 6. Circular Includes

**Wrong:**
```
main.md includes header.md
header.md includes main.md  <!-- Circular! -->
```

**Right:**
Ensure include chains never loop back.

## Performance Considerations

1. **Limit include depth** - Deep nesting slows processing
2. **Avoid excessive conditions** - Each adds processing overhead
3. **Keep marker JSON simple** - Complex structures slow parsing
4. **Use variables for repeated content** - Reduces document size

## Testing Your Documents

1. Run the validation script before publishing:
   ```bash
   python scripts/validate-mdpp.py document.md
   ```

2. Test with different condition combinations

3. Verify all includes resolve correctly

4. Check variable values are defined in ePublisher

5. Preview in ePublisher before final publish

## Integration with ePublisher

### Variable Sources

Variables can be defined in:
1. ePublisher project Variables window
2. Stationery defaults
3. Target-specific overrides

### Condition Configuration

Conditions are configured in:
1. ePublisher Conditions window
2. Per-target visibility settings
3. Job file condition overrides

### Style Mapping

Custom styles map to:
1. Stationery style definitions
2. Format-specific CSS/XSL
3. Output template configurations
