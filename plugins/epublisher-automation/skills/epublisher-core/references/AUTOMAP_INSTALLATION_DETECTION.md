# AutoMap Installation Detection

## Overview

This document describes the reliable method for detecting WebWorks ePublisher AutoMap installations on Windows systems using the Windows Registry.

## Registry-Based Detection (Recommended)

### Registry Locations

AutoMap installation information is stored in the Windows Registry at the following locations:

**64-bit Installation:**
```
HKEY_LOCAL_MACHINE\SOFTWARE\WebWorks\ePublisher AutoMap\[VERSION]
```

**32-bit Installation:**
```
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WebWorks\ePublisher AutoMap\[VERSION]
```

### Registry Key

- **Key Name:** `ExePath`
- **Value Type:** REG_SZ (String)
- **Value Content:** Full path to the AutoMap executable

Example value:
```
C:\Program Files\WebWorks\ePublisher\2024.1\ePublisher AutoMap\WebWorks.Automap.exe
```

## Detection Algorithm

### Step 1: Query Registry for Versions

1. Check `HKEY_LOCAL_MACHINE\SOFTWARE\WebWorks\ePublisher AutoMap\` for subkeys
2. If not found, check `HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WebWorks\ePublisher AutoMap\`
3. Enumerate all version subkeys (e.g., `2024.1`, `2024.2`, etc.)
4. Sort versions to find the latest installed version

### Step 2: Read ExePath

1. Navigate to the version subkey (e.g., `2024.1`)
2. Read the `ExePath` value
3. Store the full path to the executable

### Step 3: Validate Executable

1. Verify the file exists at the path retrieved from registry
2. Check file permissions (read and execute)
3. Optionally verify file signature or version information

### Step 4: Cache Path

1. Store the detected path in memory for session duration
2. Avoid repeated registry queries
3. Re-query only if execution fails (handles uninstall scenarios)

## PowerShell Implementation Example

```powershell
# Function to detect AutoMap installation
function Get-AutoMapPath {
    $registryPaths = @(
        "HKLM:\SOFTWARE\WebWorks\ePublisher AutoMap",
        "HKLM:\SOFTWARE\WOW6432Node\WebWorks\ePublisher AutoMap"
    )

    foreach ($basePath in $registryPaths) {
        if (Test-Path $basePath) {
            # Get all version subkeys
            $versions = Get-ChildItem -Path $basePath | Sort-Object Name -Descending

            foreach ($version in $versions) {
                $exePath = (Get-ItemProperty -Path $version.PSPath).ExePath

                if ($exePath -and (Test-Path $exePath)) {
                    return @{
                        Path = $exePath
                        Version = $version.PSChildName
                        Source = "Registry"
                    }
                }
            }
        }
    }

    return $null
}

# Usage
$automap = Get-AutoMapPath
if ($automap) {
    Write-Host "Found AutoMap $($automap.Version) at: $($automap.Path)"
} else {
    Write-Host "AutoMap installation not found"
}
```

## Bash/Shell Implementation Example

Using Windows `reg` command:

```bash
#!/bin/bash

# Function to detect AutoMap installation
detect_automap() {
    # Try 64-bit registry first
    local reg_path="HKLM\\SOFTWARE\\WebWorks\\ePublisher AutoMap"
    local versions=$(reg query "$reg_path" 2>/dev/null | grep "HKEY" | sed 's/.*\\//')

    # If not found, try 32-bit registry
    if [ -z "$versions" ]; then
        reg_path="HKLM\\SOFTWARE\\WOW6432Node\\WebWorks\\ePublisher AutoMap"
        versions=$(reg query "$reg_path" 2>/dev/null | grep "HKEY" | sed 's/.*\\//')
    fi

    # Get the latest version (assuming versions are sortable)
    local latest_version=$(echo "$versions" | sort -V | tail -1)

    if [ -n "$latest_version" ]; then
        local full_path="$reg_path\\$latest_version"
        local exe_path=$(reg query "$full_path" /v ExePath 2>/dev/null | grep ExePath | awk '{print $3}')

        if [ -f "$exe_path" ]; then
            echo "$exe_path"
            return 0
        fi
    fi

    return 1
}

# Usage
AUTOMAP_PATH=$(detect_automap)
if [ $? -eq 0 ]; then
    echo "Found AutoMap at: $AUTOMAP_PATH"
else
    echo "AutoMap installation not found"
fi
```

## Fallback Detection Method

If registry detection fails (rare cases: corrupted registry, portable installation, permissions issues), use these fallback methods:

### Standard Installation Paths

Check these common installation locations:

1. `C:\Program Files\WebWorks\ePublisher\[version]\ePublisher AutoMap\WebWorks.Automap.exe`
2. `C:\Program Files (x86)\WebWorks\ePublisher\[version]\ePublisher AutoMap\WebWorks.Automap.exe`

### Version Discovery

1. List directories in `C:\Program Files\WebWorks\ePublisher\`
2. Sort by version number (descending)
3. Check for `ePublisher AutoMap\WebWorks.Automap.exe` in each version directory

### User Prompt

As a last resort:
1. Inform user that AutoMap was not detected
2. Prompt user to provide the installation path
3. Validate the provided path
4. Cache the user-provided path

## Error Handling

### Common Issues

**Issue 1: Registry key not found**
- Cause: AutoMap not installed or installation corrupted
- Solution: Fallback to standard paths, then prompt user

**Issue 2: ExePath exists but file not found**
- Cause: AutoMap was uninstalled but registry not cleaned
- Solution: Try other versions, fallback to file system search

**Issue 3: Access denied to registry**
- Cause: Insufficient permissions
- Solution: Use fallback methods, inform user about permission requirements

**Issue 4: Multiple versions installed**
- Cause: User upgraded without uninstalling old version
- Solution: Use the latest version by default, allow user to specify version

## Best Practices

1. **Always query registry first** - It's the most reliable method
2. **Cache the result** - Avoid repeated registry queries
3. **Validate the executable** - Always verify the file exists before attempting execution
4. **Support both 32-bit and 64-bit** - Check both registry locations
5. **Handle multiple versions** - Default to latest, but allow override
6. **Provide clear error messages** - Guide users to resolution when detection fails
7. **Log detection method** - Record whether path came from registry, file system, or user input

## Testing Scenarios

- [ ] Fresh installation of AutoMap 2024.1 (64-bit)
- [ ] Fresh installation of AutoMap 2024.1 (32-bit on 64-bit Windows)
- [ ] Multiple versions installed (2024.1 and 2024.2)
- [ ] AutoMap uninstalled but registry entry remains
- [ ] No AutoMap installed
- [ ] Non-standard installation path
- [ ] User with limited registry permissions

## Version History

- **1.0** (2025-01-27): Initial documentation of registry-based detection method

---

**Author:** ePublisher Claude Code Skills Team
**Last Updated:** 2025-01-27
