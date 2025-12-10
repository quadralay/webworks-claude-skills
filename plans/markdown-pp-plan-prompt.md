# Markdown++ Skill Planning Prompt

Use this prompt with the Compound Engineering plan command to create a new Claude Code skill for reading and writing Markdown++ documents.

---

Create a new Claude Code skill for reading and writing Markdown++ documents. Markdown++ is an extended Markdown format created by WebWorks as both an output and interoperable source format within ePublisher 2024.1+.

## Background

Markdown++ bridges proprietary authoring tools (FrameMaker, Word, DITA-XML) and Markdown ecosystems. While created for ePublisher, it should be designed as an open format suitable for other tools and use cases to encourage adoption.

## Markdown++ Syntax Extensions (beyond CommonMark)

The format uses HTML comment tags for most extensions:

### Variables

- Syntax: `$variable_name;` (only feature NOT using HTML comments)
- Alphanumeric, hyphens, underscores allowed; no spaces
- Example: `$product_name;`, `$publish_date;`

### Custom Styles

- Syntax: `<!--style:StyleName-->` placed on line directly above element
- Inline: `<!--style:CustomBold-->**text**` (no space before element)
- Multiple commands: `<!-- style:CustomStyle ; #custom-alias -->`

### Custom Aliases

- Syntax: `<!--#alias-name-->` (alphanumeric, hyphens, underscores)
- Used for internal linking: `[link text](#alias-name)`
- Cross-document: `[link text](doc.md#alias-name)`

### Conditions

- Syntax: `<!--condition:condition_name-->content<!--/condition-->`
- Operators: space = AND, comma = OR
- Example: `<!--condition:print_only, web_only-->` (OR logic)
- Works with includes

### File Includes

- Syntax: `<!--include:path/to/file.md-->`
- Paths relative to containing file

### Markers (Metadata)

- Syntax: `<!--markers:{"Key": "value"}-->` (JSON object)
- Alternative: `<!--marker:key="value"-->`
- Used for keywords, passthrough text, etc.

### Tables

- Standard pipe tables with alignment (`:---`, `---:`, `:---:`)
- Multiline tables: `<!-- multiline -->` tag above table
- Multiline cells support full block Markdown (lists, code, paragraphs)
- Style override: `<!--style:CustomTable; multiline -->`

### Images with Styles

- Syntax: `<!--style:CustomImage-->![alt](image.png)`

## Skill Requirements

1. **Parse Markdown++ documents** - Read and validate syntax
2. **Generate Markdown++ documents** - Create properly formatted output
3. **Round-trip preservation** - Maintain extensions when editing
4. **Validation** - Detect syntax errors in extensions
5. **Conversion utilities** - Standard Markdown to/from Markdown++

## Placement Decision Needed

Should this skill be:

A) A new skill within the existing `epublisher-automation` plugin (alongside epublisher, automap, reverb)

B) A separate standalone plugin (e.g., `markdown-plus-plus`) for broader adoption

Consider:
- epublisher-automation focuses on ePublisher workflows
- Markdown++ is designed to be format-agnostic and encourage adoption outside ePublisher
- Skill would be useful for general AI/documentation workflows (ChatGPT, GitHub, etc.)

## Reference Documentation

- [Markdown++ Cheatsheet](https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.27.html)
- [Markdown++ Source Documents](https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.01.html)
- [Custom Styles](https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.22.html)
- [Multiline Tables](https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.21.html)
- [Conditions](https://webworks.com/Documentation/Reverb/Authoring%20Source%20Documents/_markdown.1.24.html)
- [Markers](https://www.webworks.com/Documentation/Reverb/Authoring%20Source%20Documents/_markdown.1.23.html)
