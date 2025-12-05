# ePublisher Customization Templates

This directory contains example templates for common ePublisher customizations.

## Contents

### SCSS Templates

- **`scss/_overrides-example.scss`** - Complete SCSS override template with:
  - Color scheme customization
  - Toolbar styling
  - Link customization
  - Navigation menu styling
  - Search box customization
  - Content area formatting
  - Responsive design patterns
  - Print styles
  - Accessibility enhancements

### ASP Templates

- **`asp/header-customization-example.asp`** - ASP header customization examples:
  - Company logo integration
  - Custom navigation links
  - Search box customization
  - Breadcrumb navigation
  - Custom toolbar buttons
  - Language and version selectors
  - Analytics integration
  - Custom JavaScript functions

### XSL Templates

- **`xsl/content-customization-example.xsl`** - XSLT transformation examples:
  - Custom paragraph processing
  - Link attribute customization
  - Note/callout formatting
  - Table responsive wrappers
  - Heading anchor generation
  - Code block syntax highlighting preparation
  - Image responsive handling
  - List customization patterns
  - Helper template functions

## Usage

These are **example files** demonstrating common customization patterns. They are not meant to be used directly.

### How to Use These Templates

1. **Identify the customization you need** from the examples
2. **Copy the actual file from your installation**:
   ```
   C:\Program Files\WebWorks\ePublisher\[version]\Formats\[FormatName]\...
   ```
3. **Apply the relevant customization pattern** from the example template
4. **Save to your project** following the parallel structure requirement:
   - Format-level: `Formats\[FormatName]\[structure]\`
   - Target-level: `Targets\[TargetName]\[structure]\`

### Important Notes

- **DO NOT** copy these example files directly to your project
- **DO** copy the actual installation files first
- **THEN** apply customization patterns from examples
- Always maintain exact parallel folder structure
- Test thoroughly with AutoMap builds
- Document all customizations with comments

## Customization Workflow

### SCSS Customizations

1. Copy `skin.scss` from installation to project
2. Create `_overrides.scss` in same directory
3. Use patterns from `scss/_overrides-example.scss`
4. Add `@import "overrides";` to end of `skin.scss`
5. Rebuild with AutoMap

### ASP Customizations

1. Copy ASP file (e.g., `Connect.asp`) from installation
2. Locate section to customize (header, footer, etc.)
3. Apply relevant patterns from `asp/header-customization-example.asp`
4. Save to project maintaining structure
5. Rebuild with AutoMap

### XSL Customizations

1. Copy XSL file from installation
2. Identify template to customize
3. Apply patterns from `xsl/content-customization-example.xsl`
4. Ensure XSLT 1.0 compatibility (no 2.0+ features)
5. Test and rebuild

## Best Practices

### General Guidelines

- Always copy from installation matching your project's Base Format Version
- Preserve exact folder and file naming (case-sensitive)
- Document all changes with clear comments
- Test customizations incrementally
- Validate output after each change
- Keep customizations minimal and focused

### SCSS Best Practices

- Use `_overrides.scss` pattern for easier maintenance
- Override variables before using in rules
- Use SCSS features sparingly (no advanced features)
- Test compiled CSS output
- Consider mobile/responsive design
- Add print styles when appropriate

### ASP Best Practices

- Add comments explaining all customizations
- Validate HTML output
- Test JavaScript in multiple browsers
- Consider accessibility (ARIA labels, keyboard navigation)
- Optimize image sizes
- Minimize inline styles (use CSS instead)

### XSL Best Practices

- Document template purpose and changes
- Use XML comments extensively
- Test with various content types
- Validate XML output well-formedness
- Keep transformations simple (performance)
- Use helper templates for reusable logic
- Remember: XSLT 1.0 only (no 2.0+ features)

## Troubleshooting

### Customization Not Appearing

- Verify parallel folder structure is exact
- Check file and folder name casing matches installation
- Rebuild with `-c` flag (clean build)
- Check ePublisher build log for errors
- Ensure format name matches exactly

### Build Errors After Customization

- Validate file syntax (ASP, SCSS, XSL)
- Check for missing dependencies or imports
- Compare with installation file version
- Review ePublisher error messages carefully
- Test with minimal changes first

### Syntax Errors

- **SCSS**: Validate with SCSS compiler
- **ASP**: Check HTML and JavaScript syntax
- **XSL**: Validate XML well-formedness and XPath expressions
- Use code editors with syntax highlighting
- Test incrementally

## Additional Resources

- **FILE_RESOLVER_GUIDE.md** - Detailed guide to override hierarchy
- **SKILL.md** - Complete skill documentation with workflows
- **AUTOMAP_INSTALLATION_DETECTION.md** - Installation detection details

## Contributing

When adding new template examples:

1. Follow existing file naming convention
2. Include comprehensive comments
3. Demonstrate real-world use cases
4. Provide before/after context
5. Note any version-specific considerations
6. Update this README with new templates

---

**Note:** These templates are part of the ePublisher Claude Code Skill project and are provided as educational examples for customization patterns.
