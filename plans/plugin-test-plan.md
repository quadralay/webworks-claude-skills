# WebWorks Agent Skills Plugin Test Plan

## Overview

This plan tests the `epublisher-automation` plugin which provides three skills:
1. **epublisher** - Core knowledge about project structure
2. **automap** - Build automation via AutoMap CLI
3. **reverb** - Browser testing and SCSS theming

## Test Projects Available

Located in `C:\wwepub`:
- `epub2479-reverb2-accessibility-upgrades` - Reverb 2.0 project
- `epub2628-reverb2-cache-buster` - Reverb 2.0 project
- `reverb2-header-dropdown` - Reverb 2.0 project
- `pdf-xsl-fo-basic-setup` - PDF output project
- `Test` - Simple test project
- `webworks-claude-code-starter/project/designer/webworks-starter.wep` - Starter project

---

## Phase 1: Installation Detection Tests

### Test 1.1: Verify AutoMap Installation Detection
```bash
# Run the detection script
bash plugins/epublisher-automation/skills/automap/scripts/detect-installation.sh

# Expected: Exit code 0, outputs path to AutoMap CLI
# If not installed: Exit code 3
```

### Test 1.2: Verify Chrome Detection
```bash
# Run Chrome detection
bash plugins/epublisher-automation/skills/reverb/scripts/detect-chrome.sh

# Expected: Exit code 0, outputs path to Chrome executable
```

### Test 1.3: Verify Node.js Dependencies
```bash
# Check Node.js version (requires 18+)
node --version

# Install dependencies if needed
cd plugins/epublisher-automation/skills/reverb
npm install
```

---

## Phase 2: Project Parsing Tests

### Test 2.1: Parse Project Targets
```bash
# Parse targets from a known project
python plugins/epublisher-automation/skills/epublisher/scripts/parse-targets.py \
  "C:\wwepub\reverb2-header-dropdown\reverb2-header-dropdown.wep"

# Expected: JSON output listing all targets in the project
```

### Test 2.2: Parse Multiple Projects
Test parsing with different project types:
- Reverb 2.0 project: `epub2479-reverb2-accessibility-upgrades`
- PDF project: `pdf-xsl-fo-basic-setup`
- Simple project: `Test`

### Test 2.3: List Source Document Groups
```bash
bash plugins/epublisher-automation/skills/epublisher/scripts/manage-sources.sh \
  list "C:\wwepub\reverb2-header-dropdown\reverb2-header-dropdown.wep"
```

---

## Phase 3: Build Automation Tests

### Test 3.1: Build a Reverb Project
```bash
# Build a known working project
bash plugins/epublisher-automation/skills/automap/scripts/automap-wrapper.sh \
  build "C:\wwepub\reverb2-header-dropdown\reverb2-header-dropdown.wep"

# Expected: Exit code 0, build completes successfully
```

### Test 3.2: Build Specific Target
```bash
# First get target names from parse-targets
# Then build specific target
bash plugins/epublisher-automation/skills/automap/scripts/automap-wrapper.sh \
  build "C:\wwepub\reverb2-header-dropdown\reverb2-header-dropdown.wep" \
  --target "TargetName"
```

### Test 3.3: Test Error Handling - Invalid Project
```bash
# Try to build non-existent project
bash plugins/epublisher-automation/skills/automap/scripts/automap-wrapper.sh \
  build "C:\wwepub\nonexistent.wep"

# Expected: Exit code 2 (Project file not found)
```

### Test 3.4: Test Error Handling - Invalid Target
```bash
bash plugins/epublisher-automation/skills/automap/scripts/automap-wrapper.sh \
  build "C:\wwepub\reverb2-header-dropdown\reverb2-header-dropdown.wep" \
  --target "InvalidTargetName"

# Expected: Exit code 4 (Invalid target name)
```

---

## Phase 4: Reverb Output Testing

### Test 4.1: Detect Entry Point
```bash
# Find the output location for a built project
bash plugins/epublisher-automation/skills/reverb/scripts/detect-entry-point.sh \
  "C:\wwepub\reverb2-header-dropdown\reverb2-header-dropdown.wep"

# Expected: Path to index.html in output directory
```

### Test 4.2: Run Browser Test
```bash
# Run headless browser test on built output
node plugins/epublisher-automation/skills/reverb/scripts/browser-test.js \
  --url "file:///C:/wwepub/reverb2-header-dropdown/Output/index.html"

# Expected: JSON output with component presence and console errors
```

### Test 4.3: Test with HTTP Server
```bash
# Start a local server (more realistic test)
cd "C:\wwepub\reverb2-header-dropdown\Output"
npx http-server -p 8080 &

# Run browser test
node plugins/epublisher-automation/skills/reverb/scripts/browser-test.js \
  --url "http://localhost:8080"

# Kill server after test
```

### Test 4.4: Validate Test Results Match Template
Compare output against `templates/test-results.json` schema:
- `success` boolean
- `components` object with expected keys
- `console_errors` array
- `parcels_loaded` boolean

---

## Phase 5: CSH Analysis Tests

### Test 5.1: Parse URL Maps
```bash
# Extract CSH mappings from a built project
python plugins/epublisher-automation/skills/reverb/scripts/parse-url-maps.py \
  "C:\wwepub\reverb2-header-dropdown\Output\url_maps.xml"

# Expected: JSON with topic-to-URL mappings
```

### Test 5.2: Verify CSH Links
After parsing URL maps, verify each link is accessible in browser test.

---

## Phase 6: SCSS Theming Tests

### Test 6.1: Extract SCSS Variables
```bash
# Extract current theme variables from a project
python plugins/epublisher-automation/skills/reverb/scripts/extract-scss-variables.py \
  "C:\wwepub\reverb2-header-dropdown"

# Expected: JSON with color variables (neo_main_color, etc.)
```

### Test 6.2: Generate Color Override
```bash
# Generate override file with custom colors
bash plugins/epublisher-automation/skills/reverb/scripts/generate-color-override.sh \
  "C:\wwepub\reverb2-header-dropdown" \
  --primary "#1a73e8" \
  --secondary "#202124"

# Expected: Creates SCSS override file
```

### Test 6.3: Rebuild and Verify Theme
After generating override:
1. Rebuild the project
2. Run browser test
3. Verify colors changed in output

---

## Phase 7: Copy Customization Tests

### Test 7.1: Copy Format Files
```bash
# Copy customization files with structure validation
python plugins/epublisher-automation/skills/epublisher/scripts/copy-customization.py \
  --source "C:\wwepub\reverb2-header-dropdown" \
  --target "C:\wwepub\Test" \
  --type format

# Expected: Files copied with correct hierarchy
```

---

## Phase 8: Report Generation Tests

### Test 8.1: Generate Test Report
```bash
# Generate structured report from test results
python plugins/epublisher-automation/skills/reverb/scripts/generate-report.py \
  --input test-results.json \
  --output report.json

# Expected: Report matching build-report.json template
```

---

## Phase 9: End-to-End Workflow Tests

### Test 9.1: Complete Build and Test Workflow
1. Parse targets from project
2. Build the project
3. Detect output entry point
4. Run browser tests
5. Generate report

### Test 9.2: Theme Customization Workflow
1. Extract current SCSS variables
2. Generate color override
3. Rebuild project
4. Verify new theme in browser

### Test 9.3: CSH Validation Workflow
1. Build project
2. Parse URL maps
3. Validate each CSH link

---

## Phase 10: Skill Invocation Tests

Test invoking skills through Claude Code:

### Test 10.1: Invoke epublisher Skill
```
User: "What is the file resolver hierarchy in ePublisher?"
Expected: Claude uses epublisher skill to explain the 4-level hierarchy
```

### Test 10.2: Invoke automap Skill
```
User: "Build the reverb2-header-dropdown project"
Expected: Claude uses automap skill to execute build
```

### Test 10.3: Invoke reverb Skill
```
User: "Test the Reverb output for console errors"
Expected: Claude uses reverb skill with browser-testing workflow
```

---

## Success Criteria

- [ ] All scripts execute without errors on valid input
- [ ] Error codes match documentation
- [ ] Output formats match templates
- [ ] Skills are invokable through Claude Code
- [ ] End-to-end workflows complete successfully
- [ ] Theme customization produces visible changes
- [ ] CSH links are correctly parsed and validated

---

## Notes

- **Platform:** Windows only (ePublisher requirement)
- **Prerequisites:** ePublisher 2024.1+, AutoMap CLI, Node.js 18+, Chrome
- **Test Duration:** Approximately 30-60 minutes for full test suite
