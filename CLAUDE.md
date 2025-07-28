# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Swift-translate is a CLI tool and Swift Package Plugin for localizing iOS/macOS apps by translating String Catalogs (`.xcstrings` files) using OpenAI's GPT models or Google Cloud Translate.

## Common Development Commands

### Build & Test
```bash
swift build                  # Build the project
swift build -c release      # Build for release
swift test                  # Run all tests
swift test -v               # Run tests with verbose output
```

### Running the CLI During Development
```bash
# Basic text translation
swift run swift-translate --verbose -k <API_KEY> --text "Hello" --lang de

# Translate a string catalog
swift run swift-translate -k <API_KEY> path/to/catalog.xcstrings --lang de,fr,it

# Use Google Translate instead of OpenAI
swift run swift-translate -s google -k <API_KEY> path/to/catalog.xcstrings
```

## Architecture & Key Components

### Core Structure
- **SwiftStringCatalog** (`Sources/SwiftStringCatalog/`) - Library for parsing/manipulating `.xcstrings` files
- **SwiftTranslate** (`Sources/SwiftTranslate/`) - Main executable with CLI and translation logic
- **Plugin** (`Plugin/`) - Swift Package Manager plugin support

### Translation Services (`Sources/SwiftTranslate/TranslationServices/`)
- Protocol-based design with `TranslationService` protocol
- `OpenAITranslator` - Supports GPT-4o and GPT-4.1 series models
- `GoogleTranslator` - Google Cloud Translate v2 integration
- Add new services by conforming to `TranslationService` protocol

### String Catalog Models
- Private models (`_StringCatalog`, `_CatalogEntry`) for JSON parsing
- Public models (`LocalizableString`, `LocalizableStringGroup`) for business logic
- Supports plural variations, device variations, and string substitutions
- Respects `shouldTranslate` flag in catalog entries

### CLI Entry Point
- `Sources/SwiftTranslate/Bootstrap/SwiftTranslate.swift` - Main CLI using Swift Argument Parser
- `TranslationCoordinator` orchestrates the translation workflow
- Supports both text and file translation modes

## Key Implementation Notes

### String Catalog Format Support
- Supports Xcode 15, 16, and 26 Beta catalog formats
- Handles complex variations (plurals, devices, substitutions)
- Only translates entries where `shouldTranslate` is true or nil
- Preserves format specifiers like `%@`, `%d`, `%lld`

### Translation Workflow
1. Parses catalog files into internal models
2. Filters strings needing translation
3. Batches requests to translation service
4. Updates catalog with translations
5. Writes to `.loc.xcstrings` files (or overwrites with `--overwrite`)

### Error Handling & Retries
- Custom `SwiftTranslateError` enum for domain errors
- Configurable retry logic for API failures
- Timeout configuration for API requests
- Validation of languages and file paths

### Testing
- Unit tests focus on String Catalog parsing
- Test resources in `Tests/Resources/`
- Use `swift test` to run tests