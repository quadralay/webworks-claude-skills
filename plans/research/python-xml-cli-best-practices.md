# Python Best Practices Research: XML Parsing, Path Handling, CLI Tools, Documentation, and Build Hooks

Research conducted: 2025-12-05

## Table of Contents

1. [XML File Parsing in Python](#1-xml-file-parsing-in-python)
2. [Windows Path Handling in Python](#2-windows-path-handling-in-python)
3. [CLI Tool Development in Python](#3-cli-tool-development-in-python)
4. [Configuration File Validation Patterns](#4-configuration-file-validation-patterns)
5. [Documentation Structure Best Practices](#5-documentation-structure-best-practices)
6. [Script Hook Patterns (Pre/Post Execution)](#6-script-hook-patterns-prepost-execution)
7. [Error Handling and Exit Codes](#7-error-handling-and-exit-codes)

---

## 1. XML File Parsing in Python

### Recommended Libraries

#### xml.etree.ElementTree (Standard Library)
- **Official Documentation**: [xml.etree.ElementTree — The ElementTree XML API](https://docs.python.org/3/library/xml.etree.elementtree.html)
- **Best for**: 90% of XML parsing tasks, learning, moderate-sized files
- **Advantages**: Built-in, no dependencies, simple API
- **Limitations**: No XPath support, slower for large files, limited namespace handling

#### lxml (Recommended for Production)
- **Context7 Library ID**: `/lxml/lxml`
- **Official Documentation**: [The lxml.etree Tutorial](https://lxml.de/tutorial.html)
- **Best for**: Complex XML processing, high performance, XPath/XSLT support
- **Key Features**:
  - Fast XML parsing (built on libxml2)
  - Full XPath and XSLT support
  - Parent element querying via `getparent()`
  - Better namespace handling
  - Multiple times faster for round-trip operations

### Best Practices

#### 1. Portable Import Pattern

Use this pattern to fall back to ElementTree if lxml is unavailable:

```python
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree
```

**Source**: [lxml Performance Documentation](https://lxml.de/performance.html)

#### 2. Basic XML Parsing Patterns

```python
from lxml import etree

# Parse from file (most efficient)
tree = etree.parse("path/to/file.xml")
root = tree.getroot()

# Parse from string
xml_string = '<root><child name="value"/></root>'
root = etree.fromstring(xml_string)

# Parse with base URL for relative path resolution
root = etree.fromstring(xml_string, base_url="http://where.it/is/from.xml")
```

**Sources**:
- [Parsing XML and HTML with lxml](https://lxml.de/parsing.html)
- [lxml ElementTree Tutorial](https://lxml.de/tutorial.html)

#### 3. Memory-Efficient Parsing for Large Files

Use `iterparse()` for streaming large XML files:

```python
from lxml import etree

# Iterative parsing with cleanup
for event, element in etree.iterparse('large_file.xml', events=('end',)):
    if element.tag == 'target_element':
        # Process element
        process(element)
        # Clean up to save memory
        element.clear(keep_tail=True)
```

**Benefits**: Processes files that don't fit in memory
**Source**: [lxml Tutorial - Iterative Parsing](https://lxml.de/tutorial.html)

#### 4. Namespace Handling

```python
# Define namespace map for clarity
namespaces = {
    'ns': 'http://example.com/namespace'
}

# Find elements with namespace
elements = root.findall('.//ns:element', namespaces)

# Use ns_clean for automatic namespace cleanup
parser = etree.XMLParser(ns_clean=True)
root = etree.fromstring(xml_string, parser)
```

**Source**: [lxml Parsing Documentation](https://lxml.de/parsing.html)

#### 5. XML Schema Validation (XSD)

```python
from lxml import etree

# Load and reuse schema for multiple validations
schema_doc = etree.parse('schema.xsd')
schema = etree.XMLSchema(schema_doc)

# Validate XML document
xml_doc = etree.parse('document.xml')
is_valid = schema.validate(xml_doc)

if not is_valid:
    # Access detailed error information
    print(schema.error_log)
```

**Best Practices**:
- Reuse `XMLSchema` objects for multiple validations (don't recreate each time)
- Use try-except blocks to catch `etree.XMLSyntaxError`
- Parse files directly rather than reading into strings (fixes encoding issues)
- Check for element existence before accessing to avoid `AttributeError`

**Sources**:
- [Validation with lxml](https://lxml.de/validation.html)
- [How to use lxml to validate XML documents against a schema](https://webscraping.ai/faq/lxml/how-do-i-use-lxml-to-validate-xml-documents-against-a-schema)
- [Stack Overflow: Validating with an XML schema in Python](https://stackoverflow.com/questions/299588/validating-with-an-xml-schema-in-python)

#### 6. Security Considerations

**Critical**: XML parsing can be vulnerable to attacks (billion laughs, external entity expansion)

```python
# Use safe parsing for untrusted sources
parser = etree.XMLParser(resolve_entities=False, no_network=True)
root = etree.fromstring(untrusted_xml, parser)
```

**Alternative**: Consider the `defusedxml` library for untrusted XML sources

**Sources**:
- [Python XML Security Documentation](https://docs.python.org/3/library/xml.html#xml-vulnerabilities)
- [ScrapingAnt: How to Parse XML in Python](https://scrapingant.com/blog/python-parse-xml)

#### 7. Serialization Best Practices

```python
# Use UTF-8 encoding for file output (not unicode)
xml_bytes = etree.tostring(root, encoding='utf-8', xml_declaration=True)

# Write to file
tree.write('output.xml', encoding='utf-8', xml_declaration=True, pretty_print=True)

# Unicode strings (for in-memory only, not parseable by other libraries)
xml_string = etree.tostring(root, encoding='unicode')
```

**Key Points**:
- Always use byte encoding (UTF-8) for file output or network transmission
- Unicode strings lack XML declarations and may not be parseable by other libraries
- UTF-8 serialization is considerably faster

**Source**: [lxml Tutorial - Serialization](https://lxml.de/tutorial.html)

### Performance Comparison

| Operation | ElementTree | cElementTree | lxml.etree |
|-----------|------------|--------------|------------|
| Parse large file | Moderate | Fast | Very Fast |
| XPath queries | Not supported | Not supported | Very Fast |
| Round-trip | Slow | Moderate | Multiple times faster |
| Memory efficiency | Moderate | Good | Excellent (with iterparse) |

**Source**: [lxml Benchmarks and Speed](https://lxml.de/performance.html)

### Example: Parsing Job XML File

```python
from lxml import etree
from pathlib import Path

def parse_job_file(job_path):
    """Parse AutoMap job XML file with proper error handling."""
    try:
        tree = etree.parse(str(job_path))
        root = tree.getroot()

        # Extract job metadata
        job_name = root.get('name')
        job_version = root.get('version')

        # Find project path
        project_elem = root.find('.//Project')
        project_path = project_elem.get('path') if project_elem is not None else None

        # Parse document files
        documents = []
        for doc in root.findall('.//Document'):
            doc_path = doc.get('path')
            if doc_path:
                documents.append(Path(doc_path))

        # Parse targets
        targets = []
        for target in root.findall('.//Target'):
            target_info = {
                'name': target.get('name'),
                'format': target.get('format'),
                'build': target.get('build') == 'True'
            }
            # Parse settings
            settings = {}
            for setting in target.findall('.//Setting'):
                settings[setting.get('name')] = setting.get('value')
            target_info['settings'] = settings
            targets.append(target_info)

        return {
            'name': job_name,
            'version': job_version,
            'project_path': project_path,
            'documents': documents,
            'targets': targets
        }

    except etree.XMLSyntaxError as e:
        raise ValueError(f"Invalid XML in {job_path}: {e}")
    except Exception as e:
        raise RuntimeError(f"Failed to parse {job_path}: {e}")
```

**Sources**:
- [Python XML Tutorial | DataCamp](https://www.datacamp.com/tutorial/python-xml-elementtree)
- [XML Parsing in Python with ElementTree & BeautifulSoup](https://mirketa.com/xml-parsing-python/)

---

## 2. Windows Path Handling in Python

### Recommended Approach: pathlib (Standard Library)

**Official Documentation**: [pathlib — Object-oriented filesystem paths](https://docs.python.org/3/library/pathlib.html)

### Best Practices

#### 1. Use pathlib as Your Default Tool

```python
from pathlib import Path

# Modern, object-oriented approach
path = Path("source") / "data" / "file.txt"

# Old way (avoid)
import os
path = os.path.join("source", "data", "file.txt")
```

**Advantages**:
- Cross-platform compatibility (same code on Windows/Linux/macOS)
- Object-oriented API
- Cleaner, more expressive syntax
- Type-safe operations

**Sources**:
- [Python's pathlib: Modern File System Paths Made Easy](https://dev.turmansolutions.ai/2025/08/05/pythons-pathlib-modern-file-system-paths-made-easy/)
- [Python's pathlib Module: Taming the File System](https://realpython.com/python-pathlib/)

#### 2. Use the `/` Operator for Path Joining

```python
# Automatically uses correct separator for OS
base_path = Path("C:/projects")
source_dir = base_path / "source" / "documents"
file_path = source_dir / "document.md"

# Works on Windows: C:\projects\source\documents\document.md
# Works on Linux: /projects/source/documents/document.md
```

**Key Point**: Path objects use the OS's native separator internally

**Source**: [Python pathlib: Comparing os.path and pathlib modules](https://www.pythonsnacks.com/p/paths-in-python-comparing-os-path-and-pathlib)

#### 3. Handling Backslash Paths from Windows

```python
# Reading Windows paths with backslashes (from XML, config files, etc.)
windows_path_string = r"Source\en\topic.md"  # Raw string

# Convert to Path object (handles backslashes automatically)
path = Path(windows_path_string)

# Or without raw string
path = Path("Source\\en\\topic.md")  # Escaped backslashes
```

**Source**: [Solved: How to Properly Write a Windows Path in a Python String Literal](https://www.sqlpey.com/python/solved-how-to-properly-write-a-windows-path-in-a-python-string-literal/)

#### 4. Resolving Relative Paths

```python
# Get absolute path
absolute_path = Path("relative/path").resolve()

# Resolve relative to a base directory
base_dir = Path("C:/wwepub/projects")
relative_path = Path("Source/en/topic.md")
full_path = (base_dir / relative_path).resolve()

# Check if path is relative to another path (Python 3.9+)
if path.is_relative_to(base_dir):
    relative = path.relative_to(base_dir)
```

**Source**: [Can Python3's pathlib Be Used Portably Between Linux and Windows?](https://www.pythontutorials.net/blog/can-python3-s-pathlib-be-used-portably-between-linux-and-windows-systems/)

#### 5. Common Directory Operations

```python
# Get current working directory
cwd = Path.cwd()

# Get user home directory
home = Path.home()

# Create directory (with parents, no error if exists)
output_dir = Path("output/build/target")
output_dir.mkdir(parents=True, exist_ok=True)

# Iterate over directory contents
for file_path in Path("source").rglob("*.md"):
    print(file_path)
```

**Source**: [10 Essential File System Operations Every Developer Should Know](https://labex.io/pythoncheatsheet/blog/python-pathlib-essentials)

#### 6. File Operations

```python
# Read file contents
content = Path("file.txt").read_text(encoding='utf-8')
binary_content = Path("file.bin").read_bytes()

# Write file contents
Path("output.txt").write_text("content", encoding='utf-8')
Path("output.bin").write_bytes(b"binary content")

# Check file properties
if path.exists():
    is_file = path.is_file()
    is_dir = path.is_dir()
    size = path.stat().st_size
```

**Benefits**: Built-in methods handle opening and closing automatically

**Source**: [pathlib — Object-oriented filesystem paths](https://docs.python.org/3/library/pathlib.html)

#### 7. Path Components and Manipulation

```python
path = Path("C:/projects/source/document.md")

# Path components
parent = path.parent              # C:/projects/source
name = path.name                  # document.md
stem = path.stem                  # document
suffix = path.suffix              # .md
parts = path.parts                # ('C:\\', 'projects', 'source', 'document.md')

# Change components
new_path = path.with_name("new_document.md")
new_path = path.with_suffix(".txt")
new_path = path.with_stem("new_document")
```

**Source**: [Pathlib module in Python - GeeksforGeeks](https://www.geeksforgeeks.org/python/pathlib-module-in-python/)

#### 8. Cross-Platform Compatibility Notes

```python
# Case sensitivity awareness
# Windows: Path("File.txt") == Path("file.txt")  # True
# Linux:   Path("File.txt") == Path("file.txt")  # False

# pathlib preserves OS behavior automatically

# Always use forward slashes in code (pathlib converts automatically)
path = Path("source/data/file.txt")  # Works on all platforms
```

**Source**: [Can Python3's pathlib Be Used Portably Between Linux and Windows?](https://www.pythontutorials.net/blog/can-python3-s-pathlib-be-used-portably-between-linux-and-windows-systems/)

#### 9. Safety Practices

```python
# Validate external input
user_path = Path(user_input)
if user_path.is_relative_to(base_dir):
    safe_path = base_dir / user_path
else:
    raise ValueError("Path outside allowed directory")

# Avoid hardcoded platform-specific paths
# Good
config_dir = Path.home() / ".config" / "myapp"

# Bad
config_dir = Path("C:\\Users\\username\\.config\\myapp")
```

**Source**: [10 Essential File System Operations Every Developer Should Know](https://labex.io/pythoncheatsheet/blog/python-pathlib-essentials)

### Example: Resolving Paths from AutoMap Job File

```python
from pathlib import Path

def resolve_job_paths(job_file_path, project_path_str, document_paths_str):
    """
    Resolve relative paths from AutoMap job file.

    Args:
        job_file_path: Path to the .wxj job file
        project_path_str: Project path from XML (e.g., "relative\\path\\to\\stationery.wxsp")
        document_paths_str: List of document paths from XML (with backslashes)

    Returns:
        Dict with resolved absolute paths
    """
    job_path = Path(job_file_path).resolve()
    job_dir = job_path.parent

    # Resolve project path (relative to job file)
    project_path = (job_dir / project_path_str).resolve()

    # Resolve document paths (relative to job file)
    documents = []
    for doc_str in document_paths_str:
        doc_path = (job_dir / doc_str).resolve()
        if doc_path.exists():
            documents.append(doc_path)
        else:
            print(f"Warning: Document not found: {doc_path}")

    return {
        'job_dir': job_dir,
        'project_path': project_path,
        'documents': documents
    }
```

**Sources**:
- [Path Representation in Python | Towards Data Science](https://towardsdatascience.com/path-representation-python-712d37917f9d/)
- [Python Path in Windows: A Comprehensive Guide](https://coderivers.org/blog/python-path-windows/)

---

## 3. CLI Tool Development in Python

### Library Comparison

| Feature | argparse | Click | Typer |
|---------|----------|-------|-------|
| **Installation** | Standard library | `pip install click` | `pip install typer` |
| **Syntax** | Verbose, imperative | Decorators, declarative | Type hints, decorators |
| **Learning Curve** | Moderate | Easy | Very Easy |
| **Type Safety** | Manual | Manual | Automatic (via type hints) |
| **Subcommands** | Robust | Excellent | Excellent |
| **Auto-completion** | Manual setup | Manual setup | Built-in |
| **Best For** | Small scripts, stdlib-only | Most applications | Modern Python (3.6+) |

**Sources**:
- [Click vs argparse - Which CLI Package is Better?](https://www.pythonsnacks.com/p/click-vs-argparse-python)
- [Comparing Python Command Line Interface Tools](https://codecut.ai/comparing-python-command-line-interface-tools-argparse-click-and-typer/)

### Recommended: Click (Context7 ID: `/pallets/click`)

**Official Documentation**: [Click Documentation](https://click.palletsprojects.com/)

**Why Click?**
- Most widely used for production CLIs
- Powers Typer underneath
- Decorator-based, composable architecture
- Excellent file/path handling
- Beautiful help pages
- Cross-platform terminal support

**Source**: [Why Click?](https://click.palletsprojects.com/en/stable/why/)

### Click Best Practices

#### 1. Basic Command Structure

```python
import click

@click.command()
@click.argument('input_file', type=click.Path(exists=True))
@click.option('--output', '-o', type=click.Path(), help='Output file path')
@click.option('--verbose', '-v', is_flag=True, help='Enable verbose output')
def process(input_file, output, verbose):
    """Process INPUT_FILE and optionally write to OUTPUT."""
    if verbose:
        click.echo(f'Processing {input_file}...')

    # Your logic here
    result = do_processing(input_file)

    if output:
        click.echo(f'Writing to {output}')
        write_output(output, result)
    else:
        click.echo(result)

if __name__ == '__main__':
    process()
```

**Source**: [Click Documentation - Context7](https://context7.com/pallets/click/llms.txt)

#### 2. File and Path Handling

```python
import click

@click.command()
@click.argument('input', type=click.File('r'))
@click.argument('output', type=click.File('w'))
@click.option('--config', type=click.Path(exists=True, dir_okay=False))
@click.option('--workdir', type=click.Path(exists=True, file_okay=False))
def process(input, output, config, workdir):
    """Process input file and write to output file."""
    try:
        data = input.read()
        result = data.upper()
        output.write(result)
        click.echo(f'Processed {input.name} -> {output.name}')
    except Exception as e:
        raise click.ClickException(f'Processing failed: {e}')
```

**Key Features**:
- `click.File('r')` / `click.File('w')`: Automatic file opening/closing
- `click.Path(exists=True)`: Validates path existence
- `dir_okay=False`: Ensures path is a file, not directory
- `file_okay=False`: Ensures path is a directory, not file

**Source**: [Click Documentation - Context7](https://context7.com/pallets/click/llms.txt)

#### 3. Custom Validation

```python
import click
from pathlib import Path

def validate_xml_file(ctx, param, value):
    """Validate that file is XML."""
    if value is None:
        return value

    path = Path(value)
    if path.suffix.lower() not in ['.xml', '.wxj']:
        raise click.BadParameter('File must have .xml or .wxj extension')

    return path

@click.command()
@click.argument('job_file', callback=validate_xml_file, type=click.Path(exists=True))
@click.option('--count', type=click.IntRange(1, 100), default=1)
@click.option('--format', type=click.Choice(['xml', 'json', 'yaml']), default='xml')
def build(job_file, count, format):
    """Build AutoMap job with validation."""
    click.echo(f'Building {job_file} (count={count}, format={format})')
```

**Source**: [Click Documentation - Context7](https://context7.com/pallets/click/llms.txt)

#### 4. Subcommands and Groups

```python
import click

@click.group()
@click.option('--config', type=click.Path(), help='Config file path')
@click.pass_context
def cli(ctx, config):
    """AutoMap build automation tool."""
    ctx.ensure_object(dict)
    ctx.obj['config'] = config

@cli.command()
@click.argument('job_file', type=click.Path(exists=True))
@click.pass_context
def build(ctx, job_file):
    """Build a job file."""
    config = ctx.obj.get('config')
    click.echo(f'Building {job_file} with config {config}')

@cli.command()
@click.pass_context
def list_jobs(ctx):
    """List available job files."""
    click.echo('Listing jobs...')

if __name__ == '__main__':
    cli()
```

**Usage**:
```bash
python tool.py --config=settings.ini build job.wxj
python tool.py list-jobs
```

**Source**: [Click Documentation](https://click.palletsprojects.com/)

#### 5. Progress Bars and User Feedback

```python
import click
import time

@click.command()
@click.argument('files', nargs=-1, type=click.Path(exists=True))
def process_files(files):
    """Process multiple files with progress bar."""
    with click.progressbar(files, label='Processing files') as bar:
        for file_path in bar:
            # Simulate processing
            time.sleep(0.5)
            process_file(file_path)

    click.secho('✓ All files processed!', fg='green')
```

**Source**: [Click Documentation](https://click.palletsprojects.com/)

#### 6. Environment Variables

```python
@click.command()
@click.option('--api-key', envvar='AUTOMAP_API_KEY', help='API key for service')
@click.option('--config', envvar='AUTOMAP_CONFIG', type=click.Path())
def deploy(api_key, config):
    """Deploy with credentials from environment."""
    if not api_key:
        raise click.ClickException('API key required (set AUTOMAP_API_KEY)')

    click.echo(f'Deploying with config: {config}')
```

**Usage**:
```bash
export AUTOMAP_API_KEY="secret"
python tool.py deploy
```

**Source**: [Click Documentation - Context7](https://context7.com/pallets/click/llms.txt)

### Alternative: Typer (for Modern Python)

**Context7 ID**: Not directly available, but part of FastAPI ecosystem
**Documentation**: [Typer Documentation](https://typer.tiangolo.com/)

```python
import typer
from pathlib import Path
from typing import Optional

app = typer.Typer()

@app.command()
def build(
    job_file: Path = typer.Argument(..., exists=True, help="Job file to build"),
    output: Optional[Path] = typer.Option(None, "--output", "-o", help="Output directory"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Verbose output")
):
    """Build an AutoMap job file."""
    if verbose:
        typer.echo(f"Building {job_file}...")

    # Your logic here
    typer.secho("✓ Build complete!", fg=typer.colors.GREEN)

if __name__ == "__main__":
    app()
```

**Benefits**:
- Uses Python type hints (more Pythonic)
- Automatic validation based on types
- Less boilerplate code
- Built-in auto-completion support

**Sources**:
- [Typer - Probably The Simplest To Use Python Command-Line Interface Library](https://towardsdatascience.com/typer-probably-the-simplest-to-use-python-command-line-interface-library-17abf1a5fd3e/)
- [Alternatives, Inspiration and Comparisons - Typer](https://typer.tiangolo.com/alternatives/)

---

## 4. Configuration File Validation Patterns

### Recommended Approach: Pydantic

**Library**: `pydantic` (with optional `pydantic-yaml` for YAML support)

### Best Practices

#### 1. Pydantic Models for Validation

```python
from pydantic import BaseModel, Field, field_validator
from pathlib import Path
from typing import List, Dict, Optional

class TargetSettings(BaseModel):
    locale: str
    output_dir: Optional[Path] = None

    @field_validator('locale')
    @classmethod
    def validate_locale(cls, v):
        if len(v) != 2:
            raise ValueError('Locale must be 2 characters')
        return v.lower()

class Target(BaseModel):
    name: str
    format: str
    build: bool = True
    settings: Dict[str, str] = Field(default_factory=dict)

class JobConfig(BaseModel):
    name: str
    version: str
    project_path: Path
    documents: List[Path]
    targets: List[Target]

    @field_validator('project_path', 'documents', mode='before')
    @classmethod
    def validate_paths(cls, v):
        """Convert string paths to Path objects."""
        if isinstance(v, list):
            return [Path(p) for p in v]
        return Path(v)

# Usage
config_dict = {
    'name': 'en',
    'version': '1.0',
    'project_path': 'path/to/project.wxsp',
    'documents': ['source/doc1.md', 'source/doc2.md'],
    'targets': [
        {
            'name': 'WebWorks Reverb 2.0',
            'format': 'WebWorks Reverb 2.0',
            'build': True,
            'settings': {'locale': 'en'}
        }
    ]
}

# Validate and parse
job_config = JobConfig(**config_dict)
```

**Benefits**:
- Type validation using Python type hints
- Automatic data conversion
- Clear error messages
- IDE auto-completion support

**Sources**:
- [Configuration files using Pydantic and YAML](https://trhallam.github.io/trhallam/blog/pydantic-yaml-config/)
- [Validating File Data - Pydantic Validation](https://docs.pydantic.dev/latest/examples/files/)

#### 2. Loading Multiple Config Formats

```python
import json
import tomllib  # Python 3.11+
from pathlib import Path
from pydantic import BaseModel

class AppConfig(BaseModel):
    automap_path: Path
    default_output: Path
    max_concurrent_builds: int = 4

def load_config(config_path: Path) -> AppConfig:
    """Load config from JSON, TOML, or YAML."""
    suffix = config_path.suffix.lower()

    if suffix == '.json':
        data = json.loads(config_path.read_text())
    elif suffix == '.toml':
        with open(config_path, 'rb') as f:
            data = tomllib.load(f)
    elif suffix in ['.yaml', '.yml']:
        import yaml
        data = yaml.safe_load(config_path.read_text())
    else:
        raise ValueError(f'Unsupported config format: {suffix}')

    return AppConfig(**data)

# Usage
config = load_config(Path('config.toml'))
```

**Source**: [Use Python to parse configuration files | Opensource.com](https://opensource.com/article/21/6/parse-configuration-files-python)

#### 3. Using python-anyconfig for Multiple Formats

```python
import anyconfig

# Supports: JSON, YAML, TOML, XML, INI, and more
config = anyconfig.load('config.toml')

# With validation
config = anyconfig.load('config.json', ac_schema='schema.json')
```

**Source**: [python-anyconfig GitHub](https://github.com/ssato/python-anyconfig)

#### 4. YAML Validation with Schema Library

```python
from schema import Schema, And, Or, Optional
import yaml

# Define validation schema
config_schema = Schema({
    'automap_path': str,
    'output_dir': str,
    'max_builds': And(int, lambda n: 0 < n < 100),
    Optional('verbose'): bool,
    'targets': [{
        'name': str,
        'format': Or('WebWorks Reverb 2.0', 'HTML5'),
        'enabled': bool
    }]
})

# Load and validate YAML
with open('config.yaml') as f:
    config_data = yaml.safe_load(f)
    validated_config = config_schema.validate(config_data)
```

**Sources**:
- [Validate YAML in Python with Schema](https://www.andrewvillazon.com/validate-yaml-python-schema/)
- [Validating File Data - Pydantic](https://docs.pydantic.dev/latest/examples/files/)

### Format Recommendations

#### TOML (Recommended for CLI Tools)
- **Pros**: Clear, unambiguous, human-friendly, no significant whitespace
- **Cons**: Less common than JSON/YAML
- **Use for**: Application settings, project configuration (like `pyproject.toml`)

```toml
[automap]
path = "C:/Program Files/WebWorks/ePublisher"
output_dir = "output"

[[targets]]
name = "WebWorks Reverb 2.0"
format = "reverb"
enabled = true
```

**Source**: [Configuration File Formats: XML, TOML, JSON, YAML, and INI Explained](https://medium.com/@ayasc/configuration-file-formats-xml-toml-json-yaml-and-ini-explained-a275fd67ee4e)

#### YAML (Good for Complex Hierarchies)
- **Pros**: Readable, supports comments, maps well to Python dicts
- **Cons**: Significant whitespace, can be ambiguous
- **Use for**: Build configurations, CI/CD pipelines

```yaml
automap:
  path: C:/Program Files/WebWorks/ePublisher
  output_dir: output

targets:
  - name: WebWorks Reverb 2.0
    format: reverb
    enabled: true
```

**Source**: [Use Python to parse configuration files](https://opensource.com/article/21/6/parse-configuration-files-python)

#### JSON (Good for Data Exchange)
- **Pros**: Ubiquitous, simple, machine-readable
- **Cons**: No comments, verbose for configs
- **Use for**: API responses, data serialization

---

## 5. Documentation Structure Best Practices

### Core Principles

#### 1. Audience-Centered Approach

**Fundamental Rule**: Write for your specific audience's skill level, role, and goals.

- Anticipate user questions
- Provide answers in immediately comprehensible format
- Tailor language to reader's expertise

**Source**: [6 Good Documentation Practices in 2025](https://technicalwriterhq.com/documentation/good-documentation-practices/)

#### 2. Logical Organization and Hierarchy

```
docs/
├── README.md                    # Project overview, quick start
├── getting-started/
│   ├── installation.md
│   ├── quick-start.md
│   └── basic-concepts.md
├── guides/
│   ├── user-guide.md            # Task-based tutorials
│   ├── automation-guide.md
│   └── troubleshooting.md
├── reference/
│   ├── api-reference.md         # Technical reference
│   ├── cli-reference.md
│   └── configuration.md
└── examples/
    ├── basic-build.md
    └── advanced-workflows.md
```

**Key Guidelines**:
- Use clear headings and subheadings
- Maximum 2 levels of subpages (avoid deep nesting)
- Group related topics together
- Maintain consistent terminology and formatting

**Sources**:
- [How to structure technical documentation: best practices](https://gitbook.com/docs/guides/docs-best-practices/documentation-structure-tips)
- [10 Technical Documentation Best Practices for 2025](https://www.wondermentapps.com/blog/technical-documentation-best-practices/)

#### 3. Document Types and Templates

**Create templates for common document types**:

**How-To Guide Template**:
```markdown
# How to [Task]

## Overview
Brief description of what will be accomplished.

## Prerequisites
- Required software/knowledge
- Environment setup

## Steps
1. Step one with explanation
2. Step two with code example
3. Step three with screenshot

## Verification
How to verify success

## Troubleshooting
Common issues and solutions

## Next Steps
Related tasks or advanced topics
```

**API Reference Template**:
```markdown
# Function/Class Name

## Description
What it does and when to use it

## Parameters
- `param1` (type): Description
- `param2` (type, optional): Description

## Returns
Return type and description

## Example
```python
# Code example
```

## Raises
Exceptions that may be raised

## See Also
Related functions/classes
```

**Source**: [Technical Documentation: Best Practices, Formats, And Examples](https://blog.invgate.com/technical-documentation)

#### 4. Task-Based Writing (Not Feature-Based)

**Good** (Task-based):
- "How to Set Up Authentication for Your Users"
- "Building Your First AutoMap Job"
- "Validating XML Job Files"

**Bad** (Feature-based):
- "User Authentication Configuration Parameters"
- "AutoMap Command-Line Options"
- "XMLSchema Class Reference"

**Source**: [9 Software Documentation Best Practices + Real Examples](https://www.atlassian.com/blog/loom/software-documentation-best-practices)

#### 5. Include Practical Examples

**Every technical concept should have**:
- Copy-paste-ready code examples
- Real-world use cases
- Expected output/results
- Common variations

```markdown
## Building a Job File

Build an AutoMap job file using the CLI:

```bash
automap build job.wxj --output=output/ --verbose
```

**Expected output**:
```
Building job: en (version 1.0)
Processing 15 documents...
Target: WebWorks Reverb 2.0 [OK]
Build completed in 2.3s
```

**Common variations**:
- Build specific target: `automap build job.wxj --target="WebWorks Reverb 2.0"`
- Dry run (validation only): `automap build job.wxj --dry-run`
```

**Source**: [10 Technical Documentation Best Practices for 2025](https://www.wondermentapps.com/blog/technical-documentation-best-practices/)

#### 6. Visual Content

**Include**:
- Screenshots for UI-based tasks
- Diagrams for architecture/workflows
- Videos for complex procedures
- Tables for comparisons

**Example: Workflow Diagram**
```
[Job File] → [Parser] → [Validator] → [Builder] → [Output]
    ↓           ↓           ↓            ↓           ↓
  (XML)    (Python)    (XSD)      (AutoMap)    (HTML)
```

**Source**: [5 Technical Documentation Trends to Shape Your 2025 Strategy](https://www.fluidtopics.com/blog/industry-trends/technical-documentation-trends-2025/)

#### 7. Modular, Focused Content

**One article = One topic/task**

**Good**:
- `requesting-parental-leave.md`
- `booking-meeting-room.md`
- `validating-job-files.md`

**Bad**:
- `hr-policies-and-procedures.md` (too broad)
- `automap-features.md` (feature-list, not task-focused)

**Source**: [6 Good Documentation Practices in 2025](https://technicalwriterhq.com/documentation/good-documentation-practices/)

#### 8. Metadata and Tagging

```markdown
---
title: Building AutoMap Jobs
category: Guides
tags: [automap, build, cli]
last_updated: 2025-12-05
difficulty: intermediate
---
```

**Benefits**:
- Easier browsing and filtering
- Improved search results
- Content maintenance tracking

**Source**: [10 Technical Documentation Best Practices for 2025](https://www.wondermentapps.com/blog/technical-documentation-best-practices/)

#### 9. Version Control Integration

**Best Practices**:
- Store docs in Git alongside code
- Use GitHub/GitLab Pages for hosting
- Tag docs with software versions
- Maintain changelog for doc updates

**Source**: [How to Write Technical Documentation in 2025: A Step-by-Step Guide](https://dev.to/auden/how-to-write-technical-documentation-in-2025-a-step-by-step-guide-1hh1)

#### 10. Regular Updates and Maintenance

**Maintenance Checklist**:
- Review docs with each release
- Test all code examples
- Update screenshots for UI changes
- Remove or archive outdated content
- Check all links (internal and external)

**Source**: [Complete Guide to Technical Documentation Best Practices](https://paligo.net/blog/how-to/the-essential-guide-to-effective-technical-documentation/)

### Documentation Style Guide Example

```markdown
# Style Guide

## Voice and Tone
- Use second person ("you") for instructions
- Active voice preferred
- Professional but friendly tone

## Formatting
- Code blocks: Use triple backticks with language identifier
- Commands: Use `code` formatting for inline commands
- File paths: Use `code` formatting
- UI elements: Use **bold** for buttons/menus

## Terminology
- Consistent term usage (decide on one term, stick with it):
  - "job file" not "job document" or "build file"
  - "target" not "output format" or "destination"

## Examples
- Always include at least one example per concept
- Show expected output
- Include error cases when relevant
```

**Source**: [7 Proven Technical Documentation Best Practices | Scribe](https://scribe.com/library/technical-documentation-best-practices)

---

## 6. Script Hook Patterns (Pre/Post Execution)

### Common Hook Patterns

#### 1. Cookiecutter-Style Hooks

**Directory Structure**:
```
project/
├── hooks/
│   ├── pre_gen_project.py     # Before project generation
│   ├── post_gen_project.py    # After project generation
│   └── pre_prompt.py           # Before user prompts
└── ...
```

**Implementation**:
```python
# hooks/pre_gen_project.py
"""Run validation before project generation."""
import sys

def validate_config():
    """Validate project configuration."""
    # Validation logic
    if not is_valid:
        print("ERROR: Invalid configuration")
        sys.exit(1)

if __name__ == '__main__':
    validate_config()
```

**Sources**:
- [Hooks — cookiecutter documentation](https://cookiecutter.readthedocs.io/en/stable/advanced/hooks.html)
- [Pattern: Software hooks | James' Coffee Blog](https://jamesg.blog/2024/06/16/software-hooks)

#### 2. Modern Build Backend Hooks (Hatch/PDM)

**Configuration in `pyproject.toml`**:
```toml
[tool.hatch.build.hooks.custom]
# Hook configuration
```

**Build Hook Plugin Example**:
```python
from hatchling.builders.hooks.plugin.interface import BuildHookInterface

class CustomBuildHook(BuildHookInterface):
    PLUGIN_NAME = 'custom'

    def initialize(self, version, build_data):
        """Run before build."""
        # Pre-build logic
        pass

    def finalize(self, version, build_data, artifact_path):
        """Run after build."""
        # Post-build logic
        pass
```

**Sources**:
- [Modern Python Build Hooks | Phylum](https://blog.phylum.io/modern-python-build-hooks/)
- [Modern Python Build Hooks | Veracode](https://www.veracode.com/blog/modern-python-build-hooks)

#### 3. Simple Callback Pattern

**Function-based hooks**:
```python
from typing import Callable, Optional

class BuildSystem:
    def __init__(self):
        self.pre_build_hooks = []
        self.post_build_hooks = []

    def register_pre_build_hook(self, hook: Callable):
        """Register a pre-build hook function."""
        self.pre_build_hooks.append(hook)

    def register_post_build_hook(self, hook: Callable):
        """Register a post-build hook function."""
        self.post_build_hooks.append(hook)

    def build(self, job_file):
        """Execute build with hooks."""
        # Run pre-build hooks
        for hook in self.pre_build_hooks:
            hook(job_file)

        # Perform build
        result = self._do_build(job_file)

        # Run post-build hooks
        for hook in self.post_build_hooks:
            hook(job_file, result)

        return result

# Usage
builder = BuildSystem()

def validate_job(job_file):
    print(f"Validating {job_file}...")
    # Validation logic

def cleanup_output(job_file, result):
    print("Cleaning up temporary files...")
    # Cleanup logic

builder.register_pre_build_hook(validate_job)
builder.register_post_build_hook(cleanup_output)

builder.build('project.wxj')
```

**Source**: [What's the preferred way to implement a hook or callback in Python?](https://stackoverflow.com/questions/4309607/whats-the-preferred-way-to-implement-a-hook-or-callback-in-python)

#### 4. File-Based Hook Discovery

**Discover and execute hook scripts**:
```python
from pathlib import Path
import subprocess
import sys

class HookManager:
    def __init__(self, hooks_dir: Path):
        self.hooks_dir = Path(hooks_dir)

    def run_hook(self, hook_name: str, *args):
        """
        Run a hook by name.

        Looks for hooks_dir/{hook_name}.py or hooks_dir/{hook_name}.sh
        """
        # Try Python hook first
        py_hook = self.hooks_dir / f"{hook_name}.py"
        if py_hook.exists():
            return self._run_python_hook(py_hook, args)

        # Try shell hook
        sh_hook = self.hooks_dir / f"{hook_name}.sh"
        if sh_hook.exists():
            return self._run_shell_hook(sh_hook, args)

        # No hook found (optional)
        return None

    def _run_python_hook(self, hook_path: Path, args):
        """Execute Python hook script."""
        result = subprocess.run(
            [sys.executable, str(hook_path), *args],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            raise RuntimeError(f"Hook {hook_path.name} failed: {result.stderr}")
        return result.stdout

    def _run_shell_hook(self, hook_path: Path, args):
        """Execute shell hook script."""
        result = subprocess.run(
            [str(hook_path), *args],
            capture_output=True,
            text=True,
            shell=True
        )
        if result.returncode != 0:
            raise RuntimeError(f"Hook {hook_path.name} failed: {result.stderr}")
        return result.stdout

# Usage
hooks = HookManager('hooks')

# Run pre-build hook
hooks.run_hook('pre_build', 'job.wxj')

# Build...

# Run post-build hook
hooks.run_hook('post_build', 'job.wxj', 'output/')
```

**Source**: [Hooks — cookiecutter documentation](https://cookiecutter.readthedocs.io/en/stable/advanced/hooks.html)

#### 5. Context Manager Pattern for Hooks

```python
from contextlib import contextmanager
from typing import Callable, List

class HookContext:
    def __init__(self, name: str):
        self.name = name
        self.pre_hooks: List[Callable] = []
        self.post_hooks: List[Callable] = []

    @contextmanager
    def execute(self, *args, **kwargs):
        """Execute hooks with context management."""
        # Pre-execution hooks
        for hook in self.pre_hooks:
            hook(self.name, *args, **kwargs)

        try:
            yield self
        finally:
            # Post-execution hooks (always run, even on error)
            for hook in self.post_hooks:
                hook(self.name, *args, **kwargs)

# Usage
build_context = HookContext('build')

def log_start(name, job_file):
    print(f"Starting {name} for {job_file}")

def log_end(name, job_file):
    print(f"Finished {name} for {job_file}")

build_context.pre_hooks.append(log_start)
build_context.post_hooks.append(log_end)

with build_context.execute(job_file='project.wxj'):
    # Perform build
    perform_build()
```

#### 6. Git-Style Hooks

**Common Git hook points**:
- `pre-commit`: Before commit is created
- `post-commit`: After commit is created
- `pre-push`: Before push to remote
- `post-merge`: After merge operation

**Using pre-commit framework**:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: local
    hooks:
      - id: validate-xml
        name: Validate XML Job Files
        entry: python scripts/validate_jobs.py
        language: python
        files: \\.wxj$
```

**Sources**:
- [My Python Programming Workflow - 2025 Edition](https://karambir.in/posts/python-programming-workflow-2025/)
- [Hooks — cookiecutter documentation](https://cookiecutter.readthedocs.io/en/stable/advanced/hooks.html)

### Hook Best Practices

1. **Cross-platform compatibility**: Use Python hooks over shell scripts
2. **Error handling**: Hooks should exit with non-zero code on failure
3. **Logging**: Provide clear output about what the hook is doing
4. **Performance**: Keep hooks fast (they run frequently)
5. **Idempotency**: Hooks should be safe to run multiple times
6. **Documentation**: Document available hooks and when they run

---

## 7. Error Handling and Exit Codes

### Standard Exit Codes

#### POSIX Exit Codes (via `os` module)

```python
import os

# Standard exit codes
os.EX_OK           # 0  - Success
os.EX_USAGE        # 64 - Command line usage error
os.EX_DATAERR      # 65 - Data format error
os.EX_NOINPUT      # 66 - Cannot open input
os.EX_NOUSER       # 67 - User unknown
os.EX_NOHOST       # 68 - Host unknown
os.EX_UNAVAILABLE  # 69 - Service unavailable
os.EX_SOFTWARE     # 70 - Internal software error
os.EX_OSERR        # 71 - System error (e.g., can't fork)
os.EX_OSFILE       # 72 - Critical OS file missing
os.EX_CANTCREAT    # 73 - Can't create output file
os.EX_IOERR        # 74 - Input/output error
os.EX_TEMPFAIL     # 75 - Temporary failure
os.EX_PROTOCOL     # 76 - Remote error in protocol
os.EX_NOPERM       # 77 - Permission denied
os.EX_CONFIG       # 78 - Configuration error
```

**Note**: Not available on Windows. Use fallback values.

**Sources**:
- [Exit codes in Python - Stack Overflow](https://stackoverflow.com/questions/285289/exit-codes-in-python)
- [Best practices when designating exit codes](https://chrisdown.name/2013/11/03/exit-code-best-practises.html)

### Best Practices

#### 1. Centralized Exit Handling

**Bad** (exit scattered throughout code):
```python
def process_file(path):
    if not path.exists():
        sys.exit(1)  # Don't do this in functions!
```

**Good** (raise exceptions, handle at top level):
```python
def process_file(path):
    if not path.exists():
        raise FileNotFoundError(f"File not found: {path}")

def main():
    try:
        process_file(Path("input.xml"))
    except FileNotFoundError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(os.EX_NOINPUT)
    except Exception as e:
        print(f"FATAL: {e}", file=sys.stderr)
        sys.exit(os.EX_SOFTWARE)
```

**Source**: [Python best practices - system exits & logging](https://github.com/ScilifelabDataCentre/dds_cli/issues/78)

#### 2. Use sys.exit() in Main Only

```python
import sys
from pathlib import Path

class JobValidationError(Exception):
    """Raised when job file validation fails."""
    pass

def validate_job(job_path: Path):
    """Validate job file, raise exception on error."""
    if not job_path.exists():
        raise FileNotFoundError(f"Job file not found: {job_path}")

    if job_path.suffix != '.wxj':
        raise JobValidationError(f"Invalid file type: {job_path.suffix}")

    # More validation...
    return True

def main(args):
    """Main entry point with centralized error handling."""
    try:
        job_path = Path(args.job_file)
        validate_job(job_path)
        # Process job...
        print("Job processed successfully")
        return 0  # Success

    except FileNotFoundError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 66  # EX_NOINPUT

    except JobValidationError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 65  # EX_DATAERR

    except KeyboardInterrupt:
        print("\nInterrupted by user", file=sys.stderr)
        return 130  # Standard for SIGINT

    except Exception as e:
        print(f"FATAL: Unexpected error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        return 70  # EX_SOFTWARE

if __name__ == '__main__':
    sys.exit(main(parse_args()))
```

**Source**: [The Ultimate Guide to Error Handling in Python](https://blog.miguelgrinberg.com/post/the-ultimate-guide-to-error-handling-in-python)

#### 3. Distinguish stdout vs stderr

```python
import sys

def log_info(message):
    """Log informational messages to stdout."""
    print(message, file=sys.stdout)

def log_error(message):
    """Log errors to stderr."""
    print(f"ERROR: {message}", file=sys.stderr)

# Usage allows separating output streams
# Command: python tool.py > output.txt 2> errors.txt
```

**Guideline**:
- **stdout**: Results, data output, success messages
- **stderr**: Errors, warnings, progress/status messages

**Source**: [Python best practices - system exits & logging](https://github.com/ScilifelabDataCentre/dds_cli/issues/78)

#### 4. Development vs Production Error Handling

```python
import sys
import traceback
from pathlib import Path

DEBUG = Path('.debug').exists()  # Or use env variable

def handle_error(error: Exception, exit_code: int = 1):
    """Handle errors differently in dev vs production."""
    if DEBUG:
        # Development: Show full traceback
        print(f"\n{'=' * 60}", file=sys.stderr)
        print("DEBUG MODE - Full Traceback:", file=sys.stderr)
        print(f"{'=' * 60}", file=sys.stderr)
        traceback.print_exc(file=sys.stderr)
        sys.exit(exit_code)
    else:
        # Production: User-friendly message only
        print(f"ERROR: {error}", file=sys.stderr)
        print("Run with DEBUG=1 for detailed information", file=sys.stderr)
        sys.exit(exit_code)

def main():
    try:
        # Your code here
        risky_operation()
    except Exception as e:
        handle_error(e, exit_code=70)

if __name__ == '__main__':
    main()
```

**Source**: [The Ultimate Guide to Error Handling in Python](https://blog.miguelgrinberg.com/post/the-ultimate-guide-to-error-handling-in-python)

#### 5. Click-Specific Error Handling

```python
import click

@click.command()
@click.argument('job_file', type=click.Path(exists=True))
def build(job_file):
    """Build AutoMap job file."""
    try:
        result = perform_build(job_file)
        click.secho('✓ Build successful', fg='green')

    except FileNotFoundError as e:
        raise click.FileError(str(job_file), hint=str(e))

    except ValueError as e:
        raise click.BadParameter(str(e))

    except Exception as e:
        # ClickException provides formatted output and sets exit code
        raise click.ClickException(f'Build failed: {e}')

if __name__ == '__main__':
    build()
```

**Click Exception Types**:
- `click.ClickException`: Generic error (exit code 1)
- `click.BadParameter`: Invalid parameter (exit code 2)
- `click.FileError`: File operation failed (exit code 1)
- `click.Abort`: User cancelled (exit code 1)

**Source**: [Click Documentation](https://click.palletsprojects.com/)

#### 6. Exception Strategy Guidelines

**Handle immediately** (can recover locally):
```python
def read_config(path):
    try:
        return json.loads(path.read_text())
    except FileNotFoundError:
        # Recover with default config
        return DEFAULT_CONFIG
```

**Re-raise with context** (add information):
```python
def process_documents(job):
    try:
        for doc in job.documents:
            process_document(doc)
    except ProcessingError as e:
        # Add context and re-raise
        raise ProcessingError(f"Failed processing job {job.name}") from e
```

**Defer** (utility functions, libraries):
```python
def parse_xml(xml_string):
    # Let exceptions bubble up - caller has more context
    return etree.fromstring(xml_string)
```

**Source**: [How to correctly handle exceptions in Python3](https://www.pythontutorials.net/blog/how-should-i-correctly-handle-exceptions-in-python3/)

#### 7. Custom Exit Codes for CLI Tools

```python
# Define custom exit codes
class ExitCode:
    OK = 0
    GENERAL_ERROR = 1
    INVALID_USAGE = 2
    FILE_NOT_FOUND = 10
    INVALID_XML = 11
    BUILD_FAILED = 20
    AUTOMAP_NOT_FOUND = 30

def main():
    try:
        # Your code
        pass
    except FileNotFoundError:
        return ExitCode.FILE_NOT_FOUND
    except XMLSyntaxError:
        return ExitCode.INVALID_XML
    except BuildError:
        return ExitCode.BUILD_FAILED

if __name__ == '__main__':
    sys.exit(main())
```

**Document exit codes** in your CLI help or README.

**Source**: [Controlling Python Exit Codes and Shell Scripts](https://www.henryleach.com/2025/02/controlling-python-exit-codes-and-shell-scripts/)

---

## Summary and Recommendations

### For AutoMap Job File Parsing

1. **XML Parsing**: Use `lxml.etree` for robust parsing with XPath support
2. **Path Handling**: Use `pathlib.Path` for all file operations
3. **Validation**: Implement XSD schema validation for job files
4. **Memory**: Use `iterparse()` for large XML files

### For CLI Tool Development

1. **Framework**: Use Click for the CLI interface
2. **Validation**: Combine Click's built-in validation with Pydantic models
3. **Configuration**: Support TOML for config files, validate with Pydantic
4. **Error Handling**: Centralize error handling in `main()`, use proper exit codes

### For Documentation

1. **Structure**: Organize by task (getting started, guides, reference)
2. **Templates**: Create templates for common document types
3. **Examples**: Include practical, copy-paste-ready examples
4. **Maintenance**: Store docs in Git, review with each release

### For Build Automation

1. **Hooks**: Implement file-based hook discovery system
2. **Validation**: Pre-build hooks for validation, post-build for cleanup
3. **Logging**: Provide clear output about build progress
4. **Error Handling**: Use specific exit codes for different failure modes

---

## External Documentation Links

### Official Python Documentation
- [xml.etree.ElementTree — The ElementTree XML API](https://docs.python.org/3/library/xml.etree.elementtree.html)
- [pathlib — Object-oriented filesystem paths](https://docs.python.org/3/library/pathlib.html)
- [8. Errors and Exceptions](https://docs.python.org/3/tutorial/errors.html)
- [Built-in Exceptions](https://docs.python.org/3/library/exceptions.html)

### Library Documentation
- [lxml Documentation](https://lxml.de/)
  - [The lxml.etree Tutorial](https://lxml.de/tutorial.html)
  - [Parsing XML and HTML](https://lxml.de/parsing.html)
  - [Validation with lxml](https://lxml.de/validation.html)
  - [Benchmarks and Speed](https://lxml.de/performance.html)
- [Click Documentation](https://click.palletsprojects.com/)
  - [Why Click?](https://click.palletsprojects.com/en/stable/why/)
- [Typer Documentation](https://typer.tiangolo.com/)
- [Pydantic Documentation](https://docs.pydantic.dev/)

### Best Practices Guides
- [Python's pathlib Module: Taming the File System – Real Python](https://realpython.com/python-pathlib/)
- [How to Parse XML in Python | ScrapingAnt](https://scrapingant.com/blog/python-parse-xml)
- [The Ultimate Guide to Error Handling in Python](https://blog.miguelgrinberg.com/post/the-ultimate-guide-to-error-handling-in-python)
- [Click vs argparse - Which CLI Package is Better?](https://www.pythonsnacks.com/p/click-vs-argparse-python)

### Documentation Structure
- [How to structure technical documentation: best practices | GitBook](https://gitbook.com/docs/guides/docs-best-practices/documentation-structure-tips)
- [10 Technical Documentation Best Practices for 2025](https://www.wondermentapps.com/blog/technical-documentation-best-practices/)
- [6 Good Documentation Practices in 2025 | Technical Writer HQ](https://technicalwriterhq.com/documentation/good-documentation-practices/)
- [Complete Guide to Technical Documentation Best Practices | Paligo](https://paligo.net/blog/how-to/the-essential-guide-to-effective-technical-documentation/)

### Build Hooks and Automation
- [Hooks — cookiecutter documentation](https://cookiecutter.readthedocs.io/en/stable/advanced/hooks.html)
- [Modern Python Build Hooks | Phylum](https://blog.phylum.io/modern-python-build-hooks/)
- [My Python Programming Workflow - 2025 Edition](https://karambir.in/posts/python-programming-workflow-2025/)

### Configuration Management
- [Use Python to parse configuration files | Opensource.com](https://opensource.com/article/21/6/parse-configuration-files-python)
- [Configuration files using Pydantic and YAML](https://trhallam.github.io/trhallam/blog/pydantic-yaml-config/)
- [Validate YAML in Python with Schema](https://www.andrewvillazon.com/validate-yaml-python-schema/)
- [Configuration File Formats: XML, TOML, JSON, YAML, and INI Explained](https://medium.com/@ayasc/configuration-file-formats-xml-toml-json-yaml-and-ini-explained-a275fd67ee4e)

### Context7 Library IDs
- lxml: `/lxml/lxml`
- Click: `/pallets/click`
- Pydantic XML: `/dapper91/pydantic-xml`

---

**Research Date**: 2025-12-05
**Status**: Comprehensive research complete with authoritative sources cited
