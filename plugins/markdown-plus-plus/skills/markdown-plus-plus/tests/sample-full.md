<!--#document-start-->
<!--markers:{"Author": "WebWorks", "Version": "1.0", "Category": "Test Document"}-->

# $product_name; Complete Feature Test

This document tests all Markdown++ extensions for validation purposes.

## Variables Test

Basic variable: $product_name;

Multiple variables: $product_name; version $version; by $author;

Variable in formatting: **$product_name;** and *$version;*

Variable in link text: [$product_name; Download]($download_url;)

Variables with special chars: $my-var; and $my_var; and $var2;

## Custom Styles Test

### Block-Level Styles

<!--style:CustomHeading-->
# Styled Heading Level 1

<!--style:CustomHeading2-->
## Styled Heading Level 2

<!--style:NoteBlock-->
> This blockquote has a custom style applied.
> It spans multiple lines.

<!--style:CodeExample-->
```python
def hello():
    """A styled code block."""
    print("Hello, $product_name;")
```

<!--style:CustomList-->
- Styled list item 1
- Styled list item 2
- Styled list item 3

<!--style:CustomParagraph-->
This entire paragraph has a custom style. It contains **bold**, *italic*, and `code` formatting.

### Inline Styles

Text with <!--style:Emphasis-->**inline styled bold**.

Text with <!--style:ProductName-->*$product_name;* inline.

A <!--style:ImportantLink-->[styled link](https://example.com) in text.

## Custom Aliases Test

<!--#introduction-->
## Introduction Section

This section has a custom alias.

<!--#getting-started-->
## Getting Started Section

Another aliased section.

<!--#detailed-alias-name-with-hyphens-->
### Section with Long Alias

Aliases can have hyphens and underscores: <!--#alias_with_underscores-->

### Links to Aliases

- See [Introduction](#introduction)
- See [Getting Started](#getting-started)
- See [Document Start](#document-start)

## Conditions Test

### Basic Conditions

<!--condition:web-->
Web-only content block.

This entire section only appears in web output.
<!--/condition-->

<!--condition:print-->
Print-only content block.

This section is for printed documentation.
<!--/condition-->

### NOT Operator

<!--condition:!internal-->
This appears when "internal" condition is hidden (external users).
<!--/condition-->

<!--condition:!draft-->
This appears when NOT in draft mode.
<!--/condition-->

### AND Operator (space)

<!--condition:web production-->
This appears when BOTH "web" AND "production" are visible.
<!--/condition-->

### OR Operator (comma)

<!--condition:web,print-->
This appears in EITHER web OR print output.
<!--/condition-->

### Complex Expressions

<!--condition:!internal,web-->
This means: NOT internal OR web
Appears if internal is hidden OR web is visible.
<!--/condition-->

<!--condition:!draft,web production-->
This means: (!draft) OR (web AND production)
Complex precedence example.
<!--/condition-->

### Nested Conditions

<!--condition:web-->
Web content starts here.

<!--condition:advanced-->
Advanced web content (nested condition).
<!--/condition-->

Regular web content continues.
<!--/condition-->

### Inline Conditions

Contact: <!--condition:web-->[email@example.com](mailto:email@example.com)<!--/condition--><!--condition:print-->see back cover<!--/condition-->.

Version: $version; <!--condition:!production-->(Development Build)<!--/condition-->

## File Includes Test

The following would include files (commented for testing):

<!-- Note: These are example includes - files don't exist in test -->
<!-- <!--include:shared/header.md--> -->
<!-- <!--include:../common/footer.md--> -->
<!-- <!--include:chapters/introduction.md--> -->

## Markers Test

### JSON Format

<!--markers:{"Keywords": "test, sample, full", "Priority": "high"}-->

### Simple Format

<!--marker:Keywords="api, documentation"-->

### Multiple Simple Markers

<!--marker:Author="WebWorks"; marker:Category="Test"-->

### Marker on Element

<!--marker:Section="features"-->
## Features Section

This section has an associated marker.

## Multiline Tables Test

### Basic Multiline

<!-- multiline -->
| Feature | Description |
|---------|-------------|
| Variables | Store reusable values.

Use `$name;` syntax. |
| Styles | Apply formatting.

Supports block and inline. |

### Multiline with Lists

<!-- multiline -->
| Step | Actions |
|------|---------|
| 1 | First step:

- Sub-action A
- Sub-action B
- Sub-action C |
| 2 | Second step:

1. Do this first
2. Then do this
3. Finally do this |

### Multiline with Code

<!-- multiline -->
| Language | Example |
|----------|---------|
| Python | ```python
def greet():
    print("Hello")
``` |
| JavaScript | ```javascript
function greet() {
    console.log("Hello");
}
``` |

### Multiline with Alignment

<!-- multiline -->
| Left | Center | Right |
|:-----|:------:|------:|
| Left aligned

Multiple lines | Center aligned

Also multiple | Right aligned

Three lines total |

## Combined Commands Test

### Style + Alias

<!-- style:CustomStyle ; #combined-example -->
## Combined Style and Alias Heading

### Style + Marker

<!-- style:ImportantSection ; marker:Priority="high" -->
## Important Section with Marker

### Style + Alias + Marker

<!-- style:FeatureBox ; #feature-1 ; marker:Keywords="feature, important" -->
### Feature with All Attributes

### Multiline + Style

<!--style:DataTable-->
<!-- multiline -->
| Column | Data |
|--------|------|
| Cell | Multi-paragraph

content here |

## Edge Cases

### Variable-like Text

Not a variable: $ standalone dollar sign
Not a variable: $no-semicolon
Not a variable: $with space;

### Empty Condition

<!--condition:test-->
<!--/condition-->

### Condition with Only Whitespace

<!--condition:whitespace-->

<!--/condition-->

### Multiple Consecutive Styles

<!--style:StyleA-->
<!--style:StyleB-->
## Heading Gets StyleB (Last Wins)

### Style with Extra Whitespace

<!-- style:SpacedStyle -->
## Heading with Spaced Style Tag

## Document End

<!--marker:Keywords="complete, test, all-features"-->

This completes the full Markdown++ feature test document.
