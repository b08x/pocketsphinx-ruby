# PocketSphinx Ruby v5 Migration Guide

This document outlines the changes needed to migrate pocketsphinx-ruby to work with PocketSphinx v5.

## Overview

PocketSphinx v5 introduced significant API changes that require updating the Ruby FFI bindings and configuration system. The main changes include:

1. **New Configuration System**: `ps_config_t` replaces `cmd_ln_t`
2. **Updated Function Signatures**: Many functions have new signatures
3. **Enhanced Error Reporting**: Better error messages from the C library
4. **Memory Management**: Improved memory handling for configuration objects

## Key Changes Made

### 1. FFI API Updates (`lib/pocketsphinx/api/`)

#### `pocketsphinx.rb`
- **Added**: New `ps_config_*` functions for configuration management
- **Added**: `ps_get_pub_err_msg()` for detailed error reporting
- **Added**: Additional decoder functions like `ps_get_cmn`, `ps_set_cmn`
- **Updated**: Function signatures to match v5 API

#### `sphinxbase.rb`
- **Removed**: Old configuration functions (moved to pocketsphinx.rb)
- **Kept**: Error logging functions (`err_set_logfile`, `err_set_logfp`)
- **Added**: Log level constants and functions

#### `sphinxad.rb`
- **No changes**: SphinxAD API remains compatible

### 2. Configuration System Refactor

#### `Configuration::Base`
- **Changed**: Constructor now uses `ps_config_init(nil)` instead of `cmd_ln_parse_r`
- **Added**: Memory management with `ObjectSpace.define_finalizer`
- **Updated**: Get/set methods use `ps_config_*` functions (no more `-` prefix)
- **Added**: `validate()`, `to_json()`, `from_json()` methods
- **Changed**: Uses `ps_config_bool()` instead of checking integer != 0

#### `Configuration::Default`
- **Updated**: Uses new `ps_default_search_args()` and `ps_expand_model_config()`
- **No breaking changes**: Public API remains the same

### 3. Enhanced Error Reporting

#### `CallHelpers`
- **Enhanced**: `api_call` now includes detailed error messages from `ps_get_pub_err_msg()`
- **Improved**: Error messages are more descriptive and helpful for debugging

### 4. Decoder Updates

#### `Decoder`
- **Compatible**: Works with new configuration system without changes
- **Improved**: Better error reporting through CallHelpers

#### `SpeechRecognizer`
- **Compatible**: No changes needed due to abstraction layers

## Breaking Changes

### Configuration Parameter Names
- **Before**: Parameter names included `-` prefix (e.g., `config['-samprate']`)
- **After**: Parameter names without `-` prefix (e.g., `config['samprate']`)

### Library Dependencies
- **Before**: Required PocketSphinx v0.8 or earlier
- **After**: Requires PocketSphinx v5.0+

### Function Signatures
- **Before**: `ps_init(cmd_ln_t *config)`
- **After**: `ps_init(ps_config_t *config)`

## Installation Requirements

### Prerequisites
1. **PocketSphinx v5**: Must be installed from source
2. **Updated Build**: Compile with CMake (not autotools)
3. **Environment**: May need to set `POCKETSPHINX_PATH` for models

### Example Installation (Ubuntu/Debian)
```bash
# Install dependencies
sudo apt-get install cmake build-essential

# Clone and build PocketSphinx v5
git clone https://github.com/cmusphinx/pocketsphinx.git
cd pocketsphinx
cmake -S . -B build
cmake --build build
sudo cmake --build build --target install
```

## Testing

### Test Suite Updates
- **Mocks**: Updated to use new FFI function names
- **Configuration**: Tests updated for new configuration API
- **Integration**: Will require PocketSphinx v5 to be installed

### Manual Testing
```ruby
# Basic configuration test
require 'pocketsphinx'
config = Pocketsphinx::Configuration.default
puts config['samprate']  # Should work without errors

# Basic decoder test
decoder = Pocketsphinx::Decoder.new(config)
# Will require actual PocketSphinx v5 library
```

## Migration Checklist

- [x] Update FFI bindings (`api/pocketsphinx.rb`)
- [x] Update Sphinxbase bindings (`api/sphinxbase.rb`)
- [x] Refactor Configuration::Base for ps_config_t
- [x] Update Configuration subclasses
- [x] Enhance error reporting in CallHelpers
- [x] Verify Decoder class compatibility
- [x] Verify SpeechRecognizer compatibility
- [ ] Update test suite mocks and expectations
- [ ] Test with actual PocketSphinx v5 installation
- [ ] Update documentation and README

## Notes

1. **Backward Compatibility**: This is a breaking change requiring PocketSphinx v5
2. **Memory Management**: New finalizer system prevents memory leaks
3. **Error Handling**: Much improved error messages from the C library
4. **JSON Support**: New configuration serialization capabilities
5. **Validation**: Built-in configuration validation

## Next Steps

1. Install PocketSphinx v5 from source
2. Test the refactored library with real audio processing
3. Update RSpec test suite for v5 compatibility
4. Update README with v5 installation instructions
5. Create integration tests for v5 features