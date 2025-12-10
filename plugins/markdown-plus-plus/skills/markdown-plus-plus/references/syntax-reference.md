# Markdown++ Syntax Reference

Complete reference for all Markdown++ extensions. This document provides detailed syntax rules, edge cases, and validation requirements.

## Base Specification

Markdown++ extends **CommonMark 0.30** with additional features. Standard CommonMark syntax works as expected. GitHub Flavored Markdown (GFM) tables are also supported.

## Variables

### Syntax

```
$variable_name;
```

### Rules

| Rule | Description |
|------|-------------|
| Start | Must begin with `$` |
| Name | Alphanumeric characters, hyphens (`-`), underscores (`_`) |
| End | Must end with semicolon (`;`) |
| Spaces | Not allowed in variable names |
| Case | Case-sensitive (`$Product;` ≠ `$product;`) |
| Length | No explicit limit, but keep names reasonable |

### Valid Examples

```markdown
$product_name;
$version;
$release-date;
$my_var_2;
$_internal;
```

### Invalid Examples

```markdown
$product name;     # Space in name
$product           # Missing semicolon
$123start;         # Cannot start with number (recommended)
$ variable;        # Space after $
```

### Usage Context

Variables can appear:
- In paragraphs: `Welcome to $product_name;.`
- In headings: `# $product_name; User Guide`
- In lists: `- Version: $version;`
- In links: `[$product_name;](https://example.com)`
- Inside formatting: `**$product_name;**`

Variables are **NOT** replaced during Markdown++ processing - they remain as literals until resolved by ePublisher or another processing tool.

---

## Custom Styles

### Syntax

```
<!--style:StyleName-->
```

### Placement Rules

| Element Type | Placement | Example |
|--------------|-----------|---------|
| Block (heading, paragraph, list, blockquote, code block, table) | Line directly above, no blank line | See below |
| Inline (bold, italic, link, code span) | Immediately before, no space | See below |

### Block-Level Placement

```markdown
<!--style:CustomHeading-->
# Heading Text

<!--style:NoteBlock-->
> Blockquote content

<!--style:CodeExample-->
```python
code here
```

<!--style:CustomList-->
- Item 1
- Item 2

<!--style:CustomTable-->
| A | B |
|---|---|
| 1 | 2 |
```

**Wrong - blank line breaks the association:**
```markdown
<!--style:CustomHeading-->

# Heading Text
```

### Inline Placement

```markdown
This is <!--style:Emphasis-->**bold text**.
Use <!--style:Code-->`inline code` here.
Click <!--style:Link-->[here](url) to continue.
```

**Wrong - space breaks the association:**
```markdown
This is <!--style: Emphasis--> **bold text**.
```

### Style Name Rules

| Rule | Description |
|------|-------------|
| Characters | Alphanumeric, hyphens, underscores |
| Spaces | Not allowed in style names |
| Case | Typically PascalCase by convention |

### Multiple Styles

If multiple style tags appear before an element, the **last one** takes precedence:

```markdown
<!--style:StyleA-->
<!--style:StyleB-->
# This heading gets StyleB
```

---

## Custom Aliases

### Syntax

```
<!--#alias-name-->
```

### Rules

| Rule | Description |
|------|-------------|
| Start | Must begin with `#` inside the comment |
| Name | Alphanumeric, hyphens, underscores |
| Spaces | Not allowed (alias ends at first space) |
| Case | Case-sensitive |

### Creating Aliases

Place the alias tag on the line above or immediately before the target element:

```markdown
<!--#introduction-->
## Introduction

This is the introduction section.
```

### Using Aliases in Links

```markdown
# Same document
See [Introduction](#introduction) for details.

# Cross-document
See [API Auth](api-reference.md#authentication) for auth info.

# Reference-style
See the [intro section][intro-ref] for more.

[intro-ref]: #introduction
```

### Alias vs. Heading IDs

Standard Markdown auto-generates IDs from headings. Custom aliases:
- Override the auto-generated ID
- Allow multiple aliases per element
- Work on non-heading elements

---

## Conditions

### Syntax

```
<!--condition:expression-->
content
<!--/condition-->
```

### Condition Expressions

| Operator | Symbol | Meaning | Precedence |
|----------|--------|---------|------------|
| NOT | `!` | Negate condition | Highest (1) |
| AND | space | All must be visible | Medium (2) |
| OR | `,` | Any can be visible | Lowest (3) |

### Expression Examples

| Expression | Interpretation |
|------------|----------------|
| `web` | Show when "web" is visible |
| `!web` | Show when "web" is hidden |
| `web print` | Show when "web" AND "print" are visible |
| `web,print` | Show when "web" OR "print" is visible |
| `!internal,web` | Show when "internal" is hidden OR "web" is visible |
| `!draft,web production` | `(!draft) OR (web AND production)` |

### Condition Name Rules

| Rule | Description |
|------|-------------|
| Characters | Alphanumeric, hyphens, underscores |
| Spaces | Separator for AND operator |
| Commas | Separator for OR operator |
| Case | Condition names are case-sensitive |

### Block Conditions

```markdown
<!--condition:web-->
## Web-Only Section

This entire section only appears in web output.

- Web feature 1
- Web feature 2
<!--/condition-->
```

### Inline Conditions

```markdown
Contact us at <!--condition:web-->[email](mailto:x@x.com)<!--/condition--><!--condition:print-->the address below<!--/condition-->.
```

### Nesting Conditions

Conditions can be nested:

```markdown
<!--condition:web-->
## Web Content

<!--condition:production-->
This appears in web AND production.
<!--/condition-->

<!--/condition-->
```

### Common Errors

| Error | Problem |
|-------|---------|
| Missing closing tag | `<!--condition:web-->` without `<!--/condition-->` |
| Typo in closing | `<!--condition-->` instead of `<!--/condition-->` |
| Mismatched nesting | Overlapping conditions |

---

## File Includes

### Syntax

```
<!--include:path/to/file.md-->
```

### Path Resolution

Paths are **relative to the containing file's directory**.

| File Location | Include Statement | Resolves To |
|---------------|-------------------|-------------|
| `docs/guide.md` | `<!--include:intro.md-->` | `docs/intro.md` |
| `docs/guide.md` | `<!--include:shared/header.md-->` | `docs/shared/header.md` |
| `docs/guide.md` | `<!--include:../common/footer.md-->` | `common/footer.md` |

### Rules

| Rule | Description |
|------|-------------|
| Placement | Must be alone on its line |
| Path | Relative to containing file |
| Extension | Typically `.md` but any text file works |
| Recursion | Included files can include other files |
| Circular | Circular includes are detected and prevented |

### Conditional Includes

```markdown
<!--condition:advanced-->
<!--include:advanced-topics.md-->
<!--/condition-->
```

### Include Processing

Included content:
- Is parsed for Markdown++ extensions
- Inherits variable context from parent
- Maintains relative paths for nested includes

### Error Handling

| Condition | Behavior |
|-----------|----------|
| File not found | Warning; include tag passes through as HTML comment |
| Circular include | Error; include is skipped with warning |

---

## Markers (Metadata)

### Syntax Options

**Preferred format (single key-value):**
```
<!--marker:Key="value"-->
```

**Multiple markers (semicolon-separated):**
```
<!--marker:Key1="value1" ; marker:Key2="value2"-->
```

**JSON format (alternative for multiple keys):**
```
<!--markers:{"Key1": "value1", "Key2": "value2"}-->
```

Use `marker:key="value"` for single markers. Use semicolon-separated format for multiple.

### JSON Format Rules

- Must be valid JSON object
- Keys and string values in double quotes
- Supports strings, numbers, booleans, arrays

```markdown
<!--markers:{"Keywords": "api, docs", "Priority": 1, "Published": true}-->
```

### Simple Format Rules

- Key followed by `=` and quoted value
- Value in double quotes
- No spaces around `=`

```markdown
<!--marker:Keywords="api, documentation"-->
```

### Placement

Markers can be placed:
- At document start (document-level metadata)
- Above elements (element-level metadata)

```markdown
<!--markers:{"Author": "WebWorks", "Version": "1.0"}-->

# Document Title

<!--marker:Keywords="introduction, overview"-->
## Introduction
```

### Common Use Cases

| Marker | Purpose |
|--------|---------|
| `Keywords` | Search keywords for Reverb |
| `Author` | Document author |
| `Category` | Content categorization |
| `Passthrough` | Content that bypasses processing |

---

## Multiline Tables

### Syntax

```
<!-- multiline -->
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

### Creating Multi-Paragraph Cells

Blank lines within a cell create multiple paragraphs:

```markdown
<!-- multiline -->
| Feature | Description |
|---------|-------------|
| Variables | Store reusable values.

Use `$name;` syntax.

Variables are resolved at build time. |
| Styles | Apply custom formatting. |
```

### Lists in Cells

```markdown
<!-- multiline -->
| Steps | Details |
|-------|---------|
| Install | 1. Download package
2. Run installer
3. Restart |
```

### Code Blocks in Cells

```markdown
<!-- multiline -->
| Example | Code |
|---------|------|
| Hello | ```python
print("Hello")
``` |
```

### Row Separation

A row containing only empty cells (or whitespace) starts a new row:

```markdown
<!-- multiline -->
| A | B |
|---|---|
| Content spans

multiple lines |
|   |   |
| New row here | Second cell |
```

### Alignment

Standard Markdown alignment syntax works:

```markdown
<!-- multiline -->
| Left | Center | Right |
|:-----|:------:|------:|
| L    | C      | R     |
```

### With Custom Styles

```markdown
<!--style:DataTable-->
<!-- multiline -->
| Column | Data |
|--------|------|
| Cell   | Content |
```

---

## Combined Commands

### Syntax

Multiple commands in one comment, separated by semicolons:

```
<!-- command1 ; command2 ; command3 -->
```

### Order Priority

When combining commands, use this order for consistency:

1. `style:StyleName` - Custom style
2. `multiline` - Multiline table indicator
3. `marker:Key="value"` - Markers (one or more)
4. `#alias-name` - Custom alias

### Supported Combinations

| Command | Syntax in Combined |
|---------|-------------------|
| Style | `style:StyleName` |
| Multiline | `multiline` |
| Marker (simple) | `marker:Key="value"` |
| Alias | `#alias-name` |

### Examples

```markdown
<!-- style:CustomHeading ; marker:Keywords="intro" ; #introduction -->
# Introduction with Style, Marker, and Alias

<!-- style:DataTable ; multiline ; #feature-table -->
| Column | Data |
|--------|------|
| Cell   | Multi-line content |

<!-- style:NoteBox ; marker:Priority="high" ; #important-note -->
> Important note with all attributes
```

### Whitespace

Spaces around semicolons are optional but recommended for readability:

```markdown
<!-- style:A;#b;marker:C="d" -->      # Valid
<!-- style:A ; #b ; marker:C="d" -->  # Valid, more readable
```

---

## Inline Styles for Images and Links

### Images

Place style immediately before the image syntax:

```markdown
<!--style:CustomImage-->![Logo](images/logo.png "Company Logo")

<!--style:ScreenshotStyle-->![Settings Screen](images/settings.png)

<!--style:IconImage-->![Warning](icons/warning.svg)
```

### Links (Style Inside Link Text)

Place style inside the link text brackets:

```markdown
[<!--style:CustomLink-->*Link text*](topics/file.md#anchor "Title")

See the [<!--style:ImportantLink-->**API Reference**](api.md#auth) for details.

Read the [<!--style:ExternalLink-->documentation](https://example.com).
```

The style applies to the formatted text within the link.

---

## Content Islands (Styled Blockquotes)

Blockquotes with custom styles create "content islands" - self-contained content blocks useful for callouts, learning boxes, or enhanced layouts.

```markdown
<!--style:BQ_Learn-->
> ## Learning Section
>
> This blockquote contains multiple elements:
>
> - Bullet point 1
> - Bullet point 2
>
> ```python
> def example():
>     return "Code inside blockquote"
> ```
>
> Final paragraph in the content island.
```

Content islands support:
- Headings within the blockquote
- Lists (ordered and unordered)
- Code blocks
- Nested formatting

---

## Validation Checks

The validation script checks for these issues:

| Code | Check | Severity |
|------|-------|----------|
| MDPP001 | Unclosed condition block | Error |
| MDPP002 | Invalid variable name | Error |
| MDPP003 | Malformed marker JSON | Error |
| MDPP004 | Invalid style placement | Warning |
| MDPP005 | Circular include | Error |
| MDPP006 | Missing include file | Warning |
| MDPP007 | Invalid condition syntax | Error |
| MDPP008 | Duplicate alias within file | Error |

---

## External References

- [Markdown++ Cheatsheet](https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.27.html)
- [CommonMark Specification](https://spec.commonmark.org/0.30/)
- [ePublisher Documentation](https://www.webworks.com/Documentation/Reverb/)
