# Markdown++ Examples

Real-world examples demonstrating common patterns and use cases.

## Example 1: Product Documentation

A typical product documentation page with variables, conditions, and styles.

```markdown
<!--markers:{"Author": "Documentation Team", "Version": "2.0"}-->
<!--#product-overview-->

# $product_name; Overview

Welcome to **$product_name;** version $version;. This guide covers installation, configuration, and basic usage.

<!--condition:web-->
> **Quick Links:** [Download](#download) | [Installation](#installation) | [Support](https://support.example.com)
<!--/condition-->

<!--condition:print-->
> See the back cover for support contact information.
<!--/condition-->

## System Requirements

<!--style:RequirementsTable-->
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | $min_os; | $rec_os; |
| RAM | $min_ram; | $rec_ram; |
| Disk | $min_disk; | $rec_disk; |

<!--#installation-->
## Installation

<!--condition:windows-->
### Windows Installation

1. Download the installer from $download_url;
2. Run `$installer_name;`
3. Follow the wizard prompts

<!--/condition-->

<!--condition:mac-->
### macOS Installation

1. Download the DMG from $download_url;
2. Drag $product_name; to Applications
3. Launch from Launchpad

<!--/condition-->

<!--condition:linux-->
### Linux Installation

```bash
sudo apt-get install $package_name;
```

Or download the tarball from $download_url;.

<!--/condition-->

## Getting Help

<!--condition:web-->
Visit our [knowledge base](https://kb.example.com) or [community forum](https://forum.example.com).
<!--/condition-->

<!--condition:print-->
See Appendix B for troubleshooting guides.
<!--/condition-->

<!--marker:Keywords="installation, setup, requirements, $product_name;"-->
```

---

## Example 2: API Reference

API documentation with code examples and conditional content.

```markdown
<!--markers:{"Category": "API Reference", "API-Version": "2.0"}-->

# Authentication API

<!--#authentication-->
## Overview

The $product_name; API uses OAuth 2.0 for authentication. All API requests must include a valid access token.

## Endpoints

<!--style:EndpointTable-->
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/token` | Get access token |
| POST | `/auth/refresh` | Refresh token |
| DELETE | `/auth/revoke` | Revoke token |

<!--#get-token-->
## Get Access Token

<!--style:HTTPExample-->
```http
POST /auth/token HTTP/1.1
Host: api.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&
client_id=$your_client_id;&
client_secret=$your_client_secret;
```

### Response

<!--style:CodeResponse-->
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

<!--condition:advanced-->
### Token Scopes

| Scope | Description |
|-------|-------------|
| `read` | Read-only access |
| `write` | Read and write access |
| `admin` | Full administrative access |

<!--/condition-->

## Error Handling

<!--style:WarningBox-->
> **Important:** Never expose your client secret in client-side code.

<!--condition:!production-->
### Debug Mode

In development, set `DEBUG=true` to get detailed error messages:

```bash
export DEBUG=true
```

<!--/condition-->

<!--marker:Keywords="authentication, oauth, token, api"-->
```

---

## Example 3: User Guide with Includes

A user guide that includes shared content from multiple files.

**Main file: `user-guide.md`**
```markdown
<!--markers:{"Document-Type": "User Guide", "Audience": "End Users"}-->

# $product_name; User Guide

<!--include:shared/header.md-->

## Introduction

This guide helps you get started with $product_name;.

<!--include:chapters/getting-started.md-->

<!--include:chapters/basic-features.md-->

<!--condition:advanced-->
<!--include:chapters/advanced-features.md-->
<!--/condition-->

<!--include:shared/footer.md-->
```

**Included file: `shared/header.md`**
```markdown
<!--style:DocumentHeader-->
> **Document Version:** $doc_version; | **Last Updated:** $last_updated;

---
```

**Included file: `chapters/getting-started.md`**
```markdown
<!--#getting-started-->
## Getting Started

### First Launch

When you first launch $product_name;, the setup wizard guides you through:

1. Creating your account
2. Configuring preferences
3. Connecting integrations

<!--style:TipBox-->
> **Tip:** You can skip the wizard and configure settings later from Preferences.
```

---

## Example 4: Multiline Tables

Complex tables with rich content in cells.

```markdown
# Feature Comparison

<!-- multiline -->
<!--style:ComparisonTable-->
| Feature | Free Plan | Pro Plan | Enterprise |
|---------|-----------|----------|------------|
| Users | Up to 5 users

No additional users allowed | Up to 50 users

$10/user after limit | Unlimited users

Volume discounts available |
| Storage | 5 GB total

No expansion options | 100 GB total

Additional storage: $5/50GB | Unlimited

Custom retention policies |
| Support | Community forum only

- Self-service docs
- FAQ section | Email support

- 24-hour response
- Priority queue | Dedicated support

- Phone hotline
- Slack channel
- Named account manager |
| Features | Basic features:

- Core functionality
- Standard reports
- Mobile app | All Free features plus:

- Advanced analytics
- API access
- Custom integrations
- SSO support | All Pro features plus:

- Custom development
- On-premise option
- SLA guarantee
- Training included |

<!--marker:Keywords="pricing, plans, features, comparison"-->
```

---

## Example 5: Conditional Platform Content

Documentation that adapts to different platforms.

```markdown
# Installation Guide

## Download

<!--condition:windows-->
Download the Windows installer (.exe) from the [downloads page]($download_url;).
<!--/condition-->

<!--condition:mac-->
Download the macOS disk image (.dmg) from the [downloads page]($download_url;).
<!--/condition-->

<!--condition:linux-->
### Package Managers

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install $package_name;
```

**Fedora/RHEL:**
```bash
sudo dnf install $package_name;
```

**Arch Linux:**
```bash
sudo pacman -S $package_name;
```
<!--/condition-->

## Configuration

The configuration file location depends on your platform:

<!--style:ConfigTable-->
| Platform | Config Location |
|----------|-----------------|
<!--condition:windows-->
| Windows | `%APPDATA%\$product_name;\config.json` |
<!--/condition-->
<!--condition:mac-->
| macOS | `~/Library/Application Support/$product_name;/config.json` |
<!--/condition-->
<!--condition:linux-->
| Linux | `~/.config/$product_name;/config.json` |
<!--/condition-->

## Verify Installation

<!--condition:windows-->
Open PowerShell and run:
```powershell
$product_name; --version
```
<!--/condition-->

<!--condition:mac,linux-->
Open Terminal and run:
```bash
$product_name; --version
```
<!--/condition-->

You should see: `$product_name; version $version;`
```

---

## Example 6: Release Notes

Release notes with version-specific content.

```markdown
<!--markers:{"Document-Type": "Release Notes"}-->
<!--#release-notes-->

# $product_name; Release Notes

## Version $version;

**Release Date:** $release_date;

### New Features

<!--style:FeatureList-->
- **Feature A**: Description of feature A
- **Feature B**: Description of feature B
- **Feature C**: Description of feature C

### Improvements

- Improved performance of $component_name;
- Enhanced UI for $feature_name;
- Better error messages for common issues

### Bug Fixes

<!--style:BugFixList-->
| Issue | Description |
|-------|-------------|
| #1234 | Fixed crash when opening large files |
| #1235 | Resolved memory leak in background process |
| #1236 | Corrected timezone handling for scheduled tasks |

### Known Issues

<!--style:WarningBox-->
> **Known Issue:** Some users may experience slow startup on first launch after update. This resolves after initial indexing completes.

<!--condition:!production-->
### Internal Notes

These notes are for internal review only:

- Performance benchmarks: See JIRA-4567
- QA sign-off: Pending
- Documentation status: In progress

<!--/condition-->

### Upgrade Instructions

<!--condition:web-->
The application updates automatically. No action required.
<!--/condition-->

<!--condition:print-->
See Section 5.2 for manual upgrade instructions.
<!--/condition-->

<!--marker:Keywords="release notes, version $version;, changelog"-->
```

---

## Example 7: Troubleshooting Guide

Troubleshooting content with conditional visibility.

```markdown
<!--#troubleshooting-->
# Troubleshooting

## Common Issues

<!--#connection-errors-->
### Connection Errors

<!--style:ProblemBox-->
> **Problem:** Cannot connect to server

**Possible Causes:**
1. Network connectivity issues
2. Firewall blocking connection
3. Server maintenance

**Solutions:**

<!--condition:windows-->
1. Check Windows Firewall settings
2. Run `netsh winsock reset` in Admin PowerShell
3. Verify proxy settings in Internet Options
<!--/condition-->

<!--condition:mac-->
1. Check System Preferences > Security & Privacy > Firewall
2. Reset network settings: `sudo dscacheutil -flushcache`
3. Verify proxy in System Preferences > Network
<!--/condition-->

<!--condition:linux-->
1. Check iptables rules: `sudo iptables -L`
2. Verify DNS: `nslookup $server_hostname;`
3. Test connection: `curl -v https://$server_hostname;`
<!--/condition-->

<!--#performance-issues-->
### Performance Issues

<!--style:ProblemBox-->
> **Problem:** Application running slowly

**Diagnostic Steps:**

1. Check system resources
   <!--condition:windows-->
   Open Task Manager (Ctrl+Shift+Esc)
   <!--/condition-->
   <!--condition:mac-->
   Open Activity Monitor
   <!--/condition-->
   <!--condition:linux-->
   Run `top` or `htop`
   <!--/condition-->

2. Clear application cache
   <!--condition:windows-->
   Delete `%APPDATA%\$product_name;\cache\*`
   <!--/condition-->
   <!--condition:mac-->
   Delete `~/Library/Caches/$product_name;/*`
   <!--/condition-->
   <!--condition:linux-->
   Delete `~/.cache/$product_name;/*`
   <!--/condition-->

3. Restart the application

<!--marker:Keywords="troubleshooting, errors, performance, help"-->
```

---

## Tips for Writing Markdown++

1. **Use variables for repeated content** - Product names, versions, URLs
2. **Use conditions for platform-specific content** - Installation, configuration
3. **Use includes for shared content** - Headers, footers, common sections
4. **Use styles for consistent formatting** - Tables, code blocks, callouts
5. **Use aliases for stable links** - Section links that survive restructuring
6. **Use markers for searchability** - Keywords, categories, metadata
