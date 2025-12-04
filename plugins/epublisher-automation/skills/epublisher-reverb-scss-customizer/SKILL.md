# epublisher-reverb-scss-customizer

Customize WebWorks Reverb 2.0 output appearance by modifying SCSS variables. This skill helps apply brand colors, adjust component styling, and create consistent visual themes.

## Quick Reference

### Apply Brand Colors (Simplest Approach)

Modify the six "neo" variables in `_colors.scss` to theme the entire output:

```scss
$neo_main_color: #008bff;           // Primary brand color (toolbar, buttons, links)
$neo_main_text_color: #222222;      // Text on primary backgrounds
$neo_secondary_color: #eeeeee;      // Secondary/sidebar background
$neo_secondary_text_color: #fefefe; // Text on dark backgrounds
$neo_tertiary_color: #222222;       // Tertiary accents (header/footer bg)
$neo_page_color: #fefefe;           // Page/content background
```

### File Locations (Override Priority)

1. **Target-Specific** (highest): `[Project]/Targets/[TargetName]/Pages/sass/_colors.scss`
2. **Format-Level**: `[Project]/Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss`
3. **Packaged Defaults** (lowest): `[Project]/Formats/WebWorks Reverb 2.0.base/Pages/sass/_colors.scss`

## SCSS Variable Categories

### Colors (`_colors.scss`)

**Layout Colors** - Quick theming via abstraction:
```scss
$_layout_color_1: $neo_main_color;      // Primary brand
$_layout_color_2: $neo_main_text_color; // Primary text
$_layout_color_3: $neo_secondary_color; // Secondary bg
$_layout_color_4: $neo_secondary_text_color; // Light text
$_layout_color_5: $neo_tertiary_color;  // Tertiary/accent
$_layout_color_6: $neo_page_color;      // Page background
```

**Component-Specific Colors:**

| Component | Key Variables |
|-----------|--------------|
| Toolbar | `$toolbar_background_color`, `$toolbar_text_color`, `$toolbar_icon_color` |
| Header | `$header_background_color`, `$header_text_color`, `$header_link_color` |
| Footer | `$footer_background_color`, `$footer_text_color`, `$footer_link_color` |
| Menu/TOC | `$menu_background_color`, `$menu_text_color`, `$menu_toc_item_*` |
| Page | `$page_background_color`, `$page_breadcrumbs_*` |
| Search | `$search_background_color`, `$search_result_*` |
| Links | `$link_default_color`, `$link_visited_color`, `$link_active_color` |

### Sizes (`_sizes.scss`)

**Component Dimensions:**
```scss
$header_height: 85px;
$footer_height: 200px;
$toolbar_height: 50px;
$menu_width: 250px;
$page_max_width: 900px;
```

**Logo Dimensions:**
```scss
$logo_generic_height: 35px;
$logo_generic_width: auto;
$toolbar_logo_height: $logo_generic_height;
$header_logo_height: $logo_generic_height;
$footer_logo_height: $logo_generic_height;
```

## Common Customization Tasks

### Task 1: Apply Corporate Brand Colors

1. Identify the project's Format directory
2. Create/edit `_colors.scss` at format level
3. Override neo variables with brand colors:

```scss
// Corporate brand override
$neo_main_color: #0052CC;           // Brand primary (Atlassian blue example)
$neo_main_text_color: #FFFFFF;      // White text on primary
$neo_secondary_color: #F4F5F7;      // Light gray sidebar
$neo_secondary_text_color: #172B4D; // Dark text
$neo_tertiary_color: #172B4D;       // Dark accents
$neo_page_color: #FFFFFF;           // White page
```

### Task 2: Customize Specific Component

Override only the specific variables needed:

```scss
// Custom toolbar with gradient
$toolbar_background_color: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
// Note: Remove darken()/lighten() calls for gradient values

// Custom footer
$footer_background_color: #1a1a2e;
$footer_text_color: #edf2f4;
```

### Task 3: Adjust Layout Sizes

Edit `_sizes.scss`:

```scss
// Wider content area
$page_max_width: 1200px;

// Narrower sidebar
$menu_width: 200px;

// Taller header for larger logo
$header_height: 120px;
$header_logo_height: 80px;
```

## Scripts

### extract-scss-variables.sh

Extract current SCSS variable values from a project:

```bash
./extract-scss-variables.sh <project-dir> [category]
```

Arguments:
- `project-dir` - Path to ePublisher project directory
- `category` - Optional: `colors`, `sizes`, `neo`, or `all` (default: `neo`)

Output: JSON with variable names and values

### generate-color-override.sh

Generate a minimal `_colors.scss` override file:

```bash
./generate-color-override.sh <output-path> \
  --main-color "#0052CC" \
  --main-text "#FFFFFF" \
  --secondary-color "#F4F5F7" \
  --secondary-text "#172B4D" \
  --tertiary-color "#172B4D" \
  --page-color "#FFFFFF"
```

## Workflow

### Customizing a Project

1. **Locate project files:**
   ```bash
   # Find SCSS files in project
   find [project-dir] -name "*.scss" -path "*/sass/*"
   ```

2. **Extract current values:**
   ```bash
   ./extract-scss-variables.sh [project-dir] neo
   ```

3. **Create override file:**
   - Copy base `_colors.scss` to format level, OR
   - Generate minimal override with only changed variables

4. **Apply changes:**
   - Edit the variables
   - Rebuild project with AutoMap

5. **Verify with browser test:**
   - Use `epublisher-reverb-browser-test` skill to verify output

## Important Notes

### Gradient Values

Gradients (`linear-gradient`, `radial-gradient`) cannot be used with `darken()` or `lighten()` functions. When using gradients:
- Set the gradient directly on the specific color property
- Remove or replace any derived colors that use `darken()`/`lighten()` on that value

### Generation Variables

Some variables in `_sizes.scss` are modified by the build process:
```scss
$header_generate: false;    // Set by FormatSetting
$footer_generate: false;    // Set by FormatSetting
$toc_generate: false;       // Set by FormatSetting
```

Do not manually set these - use FormatSettings in the project file instead.

### File Encoding

SCSS files must be UTF-8 encoded. Ensure any generated files use UTF-8.

## Examples

### Example 1: Dark Theme

```scss
$neo_main_color: #bb86fc;           // Purple accent
$neo_main_text_color: #ffffff;      // White text
$neo_secondary_color: #1e1e1e;      // Dark sidebar
$neo_secondary_text_color: #e0e0e0; // Light gray text
$neo_tertiary_color: #121212;       // Near-black accents
$neo_page_color: #1e1e1e;           // Dark page
```

### Example 2: Minimal Brand Override

Create a file with only the essential overrides:

```scss
/* Brand color override - [Company Name] */
$neo_main_color: #E63946;  // Company red
```

This single change cascades through the entire theme via the layout color system.
