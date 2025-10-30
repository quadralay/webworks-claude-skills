#!/usr/bin/env python3
"""
copy-customization.py
Copy ePublisher format files from installation to project while maintaining parallel structure

Usage:
    ./copy-customization.py [OPTIONS] --source SOURCE --destination DEST

Features:
    - Validates parallel folder structure requirements
    - Preserves exact directory hierarchy from installation
    - Creates intermediate directories as needed
    - Verifies source file exists before copying
    - Validates destination matches installation structure
    - Supports both format-level and target-level customizations

Exit Codes:
    0 - Success
    1 - Invalid arguments
    2 - Source file not found
    3 - Invalid destination path
    4 - Copy operation failed
"""

import argparse
import os
import shutil
import sys
from pathlib import Path
from typing import Optional, Tuple

# Color codes for output
class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    RED = '\033[0;31m'
    NC = '\033[0m'  # No Color

def log_info(message: str) -> None:
    """Print informational message"""
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

def log_success(message: str) -> None:
    """Print success message"""
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

def log_warning(message: str) -> None:
    """Print warning message"""
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")

def log_error(message: str) -> None:
    """Print error message to stderr"""
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}", file=sys.stderr)

def log_verbose(message: str, verbose: bool = False) -> None:
    """Print verbose message if verbose mode enabled"""
    if verbose:
        print(f"[VERBOSE] {message}", file=sys.stderr)

def validate_source_file(source_path: Path, verbose: bool = False) -> bool:
    """
    Validate that source file exists and is readable

    Args:
        source_path: Path to source file
        verbose: Enable verbose logging

    Returns:
        True if valid, False otherwise
    """
    log_verbose(f"Validating source file: {source_path}", verbose)

    if not source_path.exists():
        log_error(f"Source file does not exist: {source_path}")
        return False

    if not source_path.is_file():
        log_error(f"Source path is not a file: {source_path}")
        return False

    if not os.access(source_path, os.R_OK):
        log_error(f"Source file is not readable: {source_path}")
        return False

    log_verbose(f"Source file validation passed", verbose)
    return True

def extract_relative_path(
    source_path: Path,
    installation_root: Optional[Path] = None,
    verbose: bool = False
) -> Optional[Path]:
    """
    Extract relative path from installation Formats directory

    Args:
        source_path: Full path to source file in installation
        installation_root: Root of ePublisher installation (optional)
        verbose: Enable verbose logging

    Returns:
        Relative path from Formats directory, or None if invalid

    Example:
        Input: C:\\Program Files\\WebWorks\\ePublisher\\2024.1\\Formats\\WebWorks Reverb 2.0\\Pages\\Connect.asp
        Output: WebWorks Reverb 2.0\\Pages\\Connect.asp
    """
    log_verbose(f"Extracting relative path from: {source_path}", verbose)

    # Convert to absolute path
    source_path = source_path.resolve()

    # Try to find "Formats" in the path
    parts = source_path.parts
    try:
        formats_idx = parts.index("Formats")
        relative_parts = parts[formats_idx + 1:]
        relative_path = Path(*relative_parts)

        log_verbose(f"Extracted relative path: {relative_path}", verbose)
        return relative_path
    except ValueError:
        log_error(f"Could not find 'Formats' directory in source path: {source_path}")
        log_error("Source path must be within installation Formats directory")
        return None

def validate_destination_structure(
    destination_path: Path,
    relative_path: Path,
    verbose: bool = False
) -> bool:
    """
    Validate that destination path maintains parallel structure

    Args:
        destination_path: Destination path in project
        relative_path: Relative path from Formats directory
        verbose: Enable verbose logging

    Returns:
        True if structure is valid, False otherwise
    """
    log_verbose(f"Validating destination structure", verbose)
    log_verbose(f"  Destination: {destination_path}", verbose)
    log_verbose(f"  Relative: {relative_path}", verbose)

    # Destination must end with the same relative path
    dest_parts = destination_path.parts
    rel_parts = relative_path.parts

    if len(dest_parts) < len(rel_parts):
        log_error("Destination path is shorter than relative path")
        log_error(f"  Destination: {destination_path}")
        log_error(f"  Expected suffix: {relative_path}")
        return False

    # Check that destination ends with relative path
    dest_suffix = Path(*dest_parts[-len(rel_parts):])
    if dest_suffix != relative_path:
        log_error("Destination path does not match installation structure")
        log_error(f"  Destination suffix: {dest_suffix}")
        log_error(f"  Expected suffix: {relative_path}")
        log_warning("Parallel folder structure must be maintained exactly")
        return False

    log_verbose("Destination structure validation passed", verbose)
    return True

def create_parent_directories(
    destination_path: Path,
    dry_run: bool = False,
    verbose: bool = False
) -> bool:
    """
    Create parent directories for destination file

    Args:
        destination_path: Destination file path
        dry_run: If True, only simulate creation
        verbose: Enable verbose logging

    Returns:
        True if successful, False otherwise
    """
    parent_dir = destination_path.parent

    if parent_dir.exists():
        log_verbose(f"Parent directory already exists: {parent_dir}", verbose)
        return True

    log_info(f"Creating directory structure: {parent_dir}")

    if dry_run:
        log_info("[DRY RUN] Would create directories")
        return True

    try:
        parent_dir.mkdir(parents=True, exist_ok=True)
        log_success(f"Created directories: {parent_dir}")
        return True
    except Exception as e:
        log_error(f"Failed to create directories: {e}")
        return False

def copy_file(
    source_path: Path,
    destination_path: Path,
    force: bool = False,
    dry_run: bool = False,
    verbose: bool = False
) -> bool:
    """
    Copy file from source to destination

    Args:
        source_path: Source file path
        destination_path: Destination file path
        force: Overwrite existing file if True
        dry_run: If True, only simulate copy
        verbose: Enable verbose logging

    Returns:
        True if successful, False otherwise
    """
    log_verbose(f"Copying file", verbose)
    log_verbose(f"  From: {source_path}", verbose)
    log_verbose(f"  To: {destination_path}", verbose)

    # Check if destination exists
    if destination_path.exists():
        if not force:
            log_error(f"Destination file already exists: {destination_path}")
            log_error("Use --force to overwrite")
            return False
        else:
            log_warning(f"Overwriting existing file: {destination_path}")

    if dry_run:
        log_info("[DRY RUN] Would copy file")
        log_info(f"  From: {source_path}")
        log_info(f"  To: {destination_path}")
        return True

    try:
        shutil.copy2(source_path, destination_path)
        log_success(f"Copied: {destination_path}")

        # Verify copy
        if destination_path.exists():
            dest_size = destination_path.stat().st_size
            source_size = source_path.stat().st_size
            if dest_size == source_size:
                log_verbose(f"Verified: {dest_size} bytes", verbose)
            else:
                log_warning(f"Size mismatch: source={source_size}, dest={dest_size}")

        return True
    except Exception as e:
        log_error(f"Failed to copy file: {e}")
        return False

def perform_copy_customization(
    source: str,
    destination: str,
    installation_root: Optional[str] = None,
    force: bool = False,
    dry_run: bool = False,
    validate_only: bool = False,
    verbose: bool = False
) -> int:
    """
    Main function to copy customization file with validation

    Args:
        source: Source file path in installation
        destination: Destination file path in project
        installation_root: Root of ePublisher installation (optional)
        force: Overwrite existing files
        dry_run: Simulate operation without making changes
        validate_only: Only validate paths without copying
        verbose: Enable verbose logging

    Returns:
        Exit code (0 = success)
    """
    # Convert to Path objects
    source_path = Path(source)
    destination_path = Path(destination)
    inst_root = Path(installation_root) if installation_root else None

    log_verbose(f"Starting copy customization operation", verbose)
    log_verbose(f"  Source: {source_path}", verbose)
    log_verbose(f"  Destination: {destination_path}", verbose)

    # Validate source file
    if not validate_source_file(source_path, verbose):
        return 2

    # Extract relative path from installation
    relative_path = extract_relative_path(source_path, inst_root, verbose)
    if relative_path is None:
        return 3

    log_info(f"Format relative path: {relative_path}")

    # Validate destination structure
    if not validate_destination_structure(destination_path, relative_path, verbose):
        return 3

    if validate_only:
        log_success("Validation passed - structure is correct")
        return 0

    # Create parent directories
    if not create_parent_directories(destination_path, dry_run, verbose):
        return 4

    # Copy file
    if not copy_file(source_path, destination_path, force, dry_run, verbose):
        return 4

    # Final summary
    log_info("")
    log_success("Customization file copied successfully")
    log_info(f"Source: {source_path}")
    log_info(f"Destination: {destination_path}")
    log_info(f"Structure: {relative_path}")

    return 0

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Copy ePublisher format files while maintaining parallel structure",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Copy Connect.asp to project (format-level)
    %(prog)s --source "C:\\Program Files\\WebWorks\\ePublisher\\2024.1\\Formats\\WebWorks Reverb 2.0\\Pages\\Connect.asp" \\
             --destination "C:\\Projects\\MyDoc\\Formats\\WebWorks Reverb 2.0\\Pages\\Connect.asp"

    # Copy skin.scss to target-specific location
    %(prog)s --source "C:\\Program Files\\WebWorks\\ePublisher\\2024.1\\Formats\\WebWorks Reverb 2.0\\Pages\\sass\\skin.scss" \\
             --destination "C:\\Projects\\MyDoc\\Targets\\MyTarget\\Pages\\sass\\skin.scss"

    # Validate structure without copying
    %(prog)s --source "..." --destination "..." --validate-only

    # Dry run (simulate operation)
    %(prog)s --source "..." --destination "..." --dry-run
        """
    )

    # Required arguments
    parser.add_argument(
        "-s", "--source",
        required=True,
        help="Source file path in ePublisher installation"
    )

    parser.add_argument(
        "-d", "--destination",
        required=True,
        help="Destination file path in project"
    )

    # Optional arguments
    parser.add_argument(
        "-i", "--installation-root",
        help="Root directory of ePublisher installation (optional)"
    )

    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Overwrite existing destination file"
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate operation without making changes"
    )

    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Only validate paths without copying"
    )

    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose output"
    )

    args = parser.parse_args()

    # Execute copy operation
    exit_code = perform_copy_customization(
        source=args.source,
        destination=args.destination,
        installation_root=args.installation_root,
        force=args.force,
        dry_run=args.dry_run,
        validate_only=args.validate_only,
        verbose=args.verbose
    )

    sys.exit(exit_code)

if __name__ == "__main__":
    main()
