# Automap Skill Test Plan

## Overview

This plan covers testing the new AutoMap job file creation and management features added in PR #1.

## Prerequisites

1. **Python 3.10+** installed
2. **defusedxml** package installed: `pip install defusedxml`
3. Working directory: `plugins/epublisher-automation/skills/automap/`

## Test Categories

### Phase 1: Unit Tests - Individual Scripts

#### 1.1 parse-stationery.py

| Test | Command | Expected Result |
|------|---------|-----------------|
| Parse sample stationery | `python scripts/parse-stationery.py tests/sample.wxsp` | Shows 2 formats: "WebWorks Reverb 2.0" and "PDF - XSL-FO" |
| JSON output | `python scripts/parse-stationery.py --json tests/sample.wxsp` | Valid JSON with formats array |
| Missing file | `python scripts/parse-stationery.py missing.wxsp` | Exit code 1, error message |
| Wrong extension | `python scripts/parse-stationery.py tests/sample.waj` | Exit code 1, invalid extension error |

#### 1.2 parse-job.py

| Test | Command | Expected Result |
|------|---------|-----------------|
| Parse sample job | `python scripts/parse-job.py tests/sample.waj` | Shows job "test-job" with 2 groups, 2 targets |
| JSON output | `python scripts/parse-job.py --json tests/sample.waj` | Valid JSON structure |
| Config export | `python scripts/parse-job.py --config tests/sample.waj` | JSON compatible with create-job.py |
| Missing file | `python scripts/parse-job.py missing.waj` | Exit code 1 |

#### 1.3 validate-job.py

| Test | Command | Expected Result |
|------|---------|-----------------|
| Basic validation | `python scripts/validate-job.py tests/sample.waj` | PASSED with all checks |
| Verbose mode | `python scripts/validate-job.py -v tests/sample.waj` | Shows all check results |
| Check stationery | `python scripts/validate-job.py -s tests/sample.waj` | Validates format names against stationery |
| Missing job file | `python scripts/validate-job.py missing.waj` | Exit code 1 |

#### 1.4 list-job-targets.py

| Test | Command | Expected Result |
|------|---------|-----------------|
| List targets | `python scripts/list-job-targets.py tests/sample.waj` | Shows 2 targets, 1 enabled |
| Enabled only | `python scripts/list-job-targets.py -e tests/sample.waj` | Shows only "WebWorks Reverb 2.0" |
| Disabled only | `python scripts/list-job-targets.py -d tests/sample.waj` | Shows only "PDF - XSL-FO" |
| Detailed | `python scripts/list-job-targets.py --detailed tests/sample.waj` | Shows conditions, variables, settings |
| JSON output | `python scripts/list-job-targets.py --json tests/sample.waj` | Valid JSON array |

#### 1.5 create-job.py

| Test | Command | Expected Result |
|------|---------|-----------------|
| Template generation | `python scripts/create-job.py --template -s tests/sample.wxsp` | JSON template with both formats |
| Config mode | See Phase 2 integration tests | Creates valid .waj file |
| Missing stationery | `python scripts/create-job.py -s missing.wxsp` | Exit code 1 |
| Help | `python scripts/create-job.py --help` | Shows usage with examples |

### Phase 2: Integration Tests - Workflows

#### 2.1 Round-Trip Test

1. Parse existing job to config:
   ```bash
   python scripts/parse-job.py --config tests/sample.waj > test-config.json
   ```

2. Create new job from config:
   ```bash
   python scripts/create-job.py --config test-config.json --output test-roundtrip.waj -y
   ```

3. Validate new job:
   ```bash
   python scripts/validate-job.py test-roundtrip.waj
   ```

4. Compare targets:
   ```bash
   python scripts/list-job-targets.py --json tests/sample.waj > original.json
   python scripts/list-job-targets.py --json test-roundtrip.waj > roundtrip.json
   # Verify target names and formats match
   ```

**Expected Result:** Round-trip produces functionally equivalent job file.

#### 2.2 Template-Based Creation

1. Generate template from stationery:
   ```bash
   python scripts/create-job.py --template -s tests/sample.wxsp > template.json
   ```

2. Modify template (add documents, adjust targets)

3. Create job from modified template:
   ```bash
   python scripts/create-job.py --config template.json --output from-template.waj -y
   ```

4. Validate result:
   ```bash
   python scripts/validate-job.py from-template.waj
   ```

### Phase 3: Security Tests

#### 3.1 XXE Protection (defusedxml)

Create malicious XML file `tests/xxe-test.waj`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<Job name="&xxe;" version="1.0">
  <Project path="test.wxsp"/>
  <Targets>
    <Target name="Test" format="Test" build="True"/>
  </Targets>
</Job>
```

| Test | Command | Expected Result |
|------|---------|-----------------|
| XXE blocked in parse-job | `python scripts/parse-job.py tests/xxe-test.waj` | Parse error, no file content leaked |
| XXE blocked in validate-job | `python scripts/validate-job.py tests/xxe-test.waj` | Parse error, entity not expanded |
| XXE blocked in list-targets | `python scripts/list-job-targets.py tests/xxe-test.waj` | Parse error |

#### 3.2 Path Traversal Protection

Create config with path traversal attempt `tests/traversal-config.json`:
```json
{
  "name": "test",
  "stationery": "sample.wxsp",
  "targets": [{"name": "Test", "format": "Test", "build": true}]
}
```

| Test | Command | Expected Result |
|------|---------|-----------------|
| Output path traversal | `python scripts/create-job.py --config tests/traversal-config.json -o "../../../tmp/evil.waj" -y` | Error: Path traversal attempt detected |
| Job name sanitization | Create job with name `../../../etc/passwd` | Sanitized to safe filename |

#### 3.3 Config Validation

Create invalid config `tests/invalid-config.json`:
```json
{
  "name": "",
  "stationery": "",
  "targets": []
}
```

| Test | Command | Expected Result |
|------|---------|-----------------|
| Empty config | `python scripts/create-job.py --config tests/invalid-config.json -y` | Exit code 3, validation errors for name, stationery, targets |

### Phase 4: Edge Cases

#### 4.1 Empty/Minimal Files

| Test | Expected Result |
|------|-----------------|
| Stationery with no formats | Exit code 3, "No formats found" |
| Job file with no targets | Validation fails |
| Job file with empty groups | Warning, validation passes |

#### 4.2 Special Characters

| Test | Expected Result |
|------|-----------------|
| Job name with unicode | Sanitized appropriately |
| Document paths with spaces | Handled correctly |
| Stationery path with backslashes | Works on Windows |

### Phase 5: Output Verification

#### 5.1 Generated XML Structure

Verify `create-job.py` output contains:
- [ ] XML declaration: `<?xml version="1.0" encoding="utf-8"?>`
- [ ] Root `<Job>` element with `name` and `version` attributes
- [ ] `<Project path="..."/>` element
- [ ] `<Files>` section with `<Group>` and `<Document>` elements
- [ ] `<Targets>` section with `<Target>` elements
- [ ] Target attributes: name, format, formatType, build, deployTarget, cleanOutput
- [ ] Nested elements: Conditions, Variables, Settings (when present)

#### 5.2 Atomic Write Verification

1. Create a large config that generates substantial output
2. During write, simulate interruption (Ctrl+C)
3. Verify original file is not corrupted
4. Verify no partial temp files remain

## Test Execution Checklist

```bash
# Setup
cd plugins/epublisher-automation/skills/automap/
pip install defusedxml

# Phase 1: Unit tests
python scripts/parse-stationery.py tests/sample.wxsp
python scripts/parse-stationery.py --json tests/sample.wxsp
python scripts/parse-job.py tests/sample.waj
python scripts/parse-job.py --json tests/sample.waj
python scripts/validate-job.py tests/sample.waj
python scripts/validate-job.py -v tests/sample.waj
python scripts/list-job-targets.py tests/sample.waj
python scripts/list-job-targets.py -e tests/sample.waj
python scripts/list-job-targets.py --detailed tests/sample.waj
python scripts/create-job.py --template -s tests/sample.wxsp

# Phase 2: Integration
python scripts/parse-job.py --config tests/sample.waj > test-config.json
python scripts/create-job.py --config test-config.json -o test-roundtrip.waj -y
python scripts/validate-job.py test-roundtrip.waj

# Cleanup
rm -f test-config.json test-roundtrip.waj template.json from-template.waj
rm -f original.json roundtrip.json
```

## Success Criteria

- [ ] All unit tests pass with expected exit codes
- [ ] Round-trip test produces valid job file
- [ ] XXE attacks are blocked (defusedxml working)
- [ ] Path traversal attempts are rejected
- [ ] Invalid configs produce clear error messages
- [ ] Generated XML is well-formed and valid
- [ ] All scripts show proper help with `--help`
