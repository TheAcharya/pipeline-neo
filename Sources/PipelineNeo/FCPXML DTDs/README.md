# FCPXML DTDs

This directory contains FCPXML DTD (Document Type Definition) files for versions 1.5 through 1.13, providing comprehensive support for Final Cut Pro XML workflows.

## Supported Versions

Pipeline Neo supports the following FCPXML versions:

- FCPXML 1.5 - Early version support
- FCPXML 1.6 - Enhanced feature set
- FCPXML 1.7 - Additional capabilities
- FCPXML 1.8 - Improved structure
- FCPXML 1.9 - Enhanced functionality
- FCPXML 1.10 - Advanced features
- FCPXML 1.11 - Latest improvements
- FCPXML 1.12 - Modern enhancements
- FCPXML 1.13 - Current latest version

## Usage

The DTD files are included as resources in the PipelineNeo package and can be used for:

- FCPXML validation against official schemas
- Version detection and compatibility checking
- Document structure validation
- Element and attribute validation
- Cross-version compatibility testing

## File Naming Convention

DTD files follow the naming convention: `Final_Cut_Pro_XML_DTD_version_{version}.dtd`

Examples:
- `Final_Cut_Pro_XML_DTD_version_1.5.dtd`
- `Final_Cut_Pro_XML_DTD_version_1.13.dtd`

## Integration

These DTD files are automatically used by the Pipeline Neo framework for:

- Document validation during parsing
- Version-specific element handling
- Schema compliance checking
- Error reporting and diagnostics

## Current Status

- All DTD files validated and tested
- Full version support (1.5-1.13)
- Comprehensive validation coverage
- Thread-safe and concurrency-compliant 