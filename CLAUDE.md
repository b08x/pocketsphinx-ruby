# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Testing
- `bundle exec rspec` - Run all tests
- `bundle exec rspec spec/decoder_spec.rb` - Run a specific test file
- `bundle exec rspec spec/integration/` - Run integration tests

### Building and Installing
- `bundle install` - Install dependencies
- `bundle exec rake build` - Build the gem
- `bundle exec rake install` - Install the gem locally
- `bundle exec rake clean` - Clean build artifacts

### Default Task
- `bundle exec rake` - Runs the default task (specs)

## Code Architecture

This is a Ruby FFI (Foreign Function Interface) binding for the Pocketsphinx speech recognition library. The codebase is organized into several key architectural layers:

### FFI API Layer (`lib/pocketsphinx/api/`)
- **sphinxbase.rb** - Bindings for libsphinxbase functions
- **sphinxad.rb** - Bindings for libsphinxad audio functions  
- **pocketsphinx.rb** - Bindings for libpocketsphinx core functions
- **call_helpers.rb** - Helper utilities for making FFI calls

### Configuration System (`lib/pocketsphinx/configuration/`)
- **base.rb** - Base configuration class with setting management
- **default.rb** - Default Pocketsphinx configuration
- **keyword_spotting.rb** - Configuration for keyword spotting mode
- **grammar.rb** - Configuration for grammar-based recognition
- **setting_definition.rb** - Defines individual configuration settings

### Core Recognition Classes
- **Decoder** - Low-level decoder interface to libpocketsphinx
- **Microphone** - Audio input handling via libsphinxad
- **AudioFile** - Audio file input handling
- **LiveSpeechRecognizer** - High-level live speech recognition
- **AudioFileSpeechRecognizer** - High-level file-based recognition
- **SpeechRecognizer** - Base class for speech recognizers

### Grammar System (`lib/pocketsphinx/grammar/`)
- **jsgf.rb** - JSGF grammar file handling
- **jsgf_builder.rb** - DSL for building JSGF grammars dynamically

## Key Dependencies

- **FFI** - For C library bindings
- **Pocketsphinx** - The underlying speech recognition library (libpocketsphinx)
- **Sphinxbase** - Base CMU Sphinx functionality (libsphinxbase)
- **Sphinxad** - Audio device handling (libsphinxad)

## Testing Structure

Tests are organized into unit tests and integration tests:
- Unit tests in `spec/` for individual classes
- Integration tests in `spec/integration/` for end-to-end functionality
- Audio assets in `spec/assets/audio/` for testing recognition

## Development Notes

- The gem requires development versions of CMU Sphinx libraries (not the stable 0.8 release)
- FFI bindings are preferred over SWIG for maintenance and JRuby compatibility
- Configuration objects are mutable and can be modified before passing to recognizers
- The Decoder class automatically updates configuration with acoustic model settings
- Voice Activity Detection (VAD) is used for utterance segmentation by default