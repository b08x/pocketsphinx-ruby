# PocketSphinx Ruby Examples

This directory contains examples demonstrating the pocketsphinx-ruby gem with PocketSphinx v5.

## Prerequisites

Before running these examples, ensure you have:

1. **PocketSphinx v5** installed from source (see main README)
2. **PortAudio** installed for microphone support:
   - Ubuntu/Debian: `sudo apt-get install libportaudio2 libportaudio-dev`
   - Fedora/RHEL: `sudo dnf install portaudio portaudio-devel`
   - macOS: `brew install portaudio`
3. **Working microphone** for live audio examples
4. **Dependencies installed**: `bundle install`

## Examples

### Basic Examples

#### `decode_audio_file.rb`
Basic file-based speech recognition. Demonstrates:
- Loading and decoding a raw audio file
- Getting recognition hypothesis
- Extracting word-level timing information

```bash
ruby examples/decode_audio_file.rb
```

#### `pocketsphinx_continuous.rb`
Continuous live speech recognition using the high-level API. Demonstrates:
- Real-time speech recognition
- Endpointer-based Voice Activity Detection
- Simple recognition loop

```bash
ruby examples/pocketsphinx_continuous.rb
```

### Audio Examples

#### `record_audio_file.rb`
Record audio to a file using frame-based processing. Demonstrates:
- PortAudio-based audio recording
- Frame-aligned audio capture
- Endpointer frame size usage

```bash
ruby examples/record_audio_file.rb
```

### Advanced Examples

#### `endpointer_demo.rb`
Voice Activity Detection (VAD) without recognition. Demonstrates:
- PocketSphinx v5 endpointer functionality
- Speech start/end detection
- Real-time speech activity monitoring

```bash
ruby examples/endpointer_demo.rb
```

#### `advanced_recognition.rb`
Advanced recognition with custom configuration. Demonstrates:
- Custom endpointer parameters
- Partial and final recognition results
- Manual integration of endpointer and decoder
- Speech timing information

```bash
ruby examples/advanced_recognition.rb
```

#### `keyword_spotter.rb`
Keyword spotting with dynamic reconfiguration. Demonstrates:
- Keyword-based recognition
- Dynamic configuration changes
- Context switching

```bash
ruby examples/keyword_spotter.rb
```

## New in PocketSphinx v5

### Endpointer-based VAD
PocketSphinx v5 introduced a new endpointer system for Voice Activity Detection, replacing the old `ps_get_in_speech()` approach. The endpointer provides:

- **Frame-based processing**: Uses fixed frame sizes (typically 480 samples at 16kHz)
- **Proper speech segmentation**: Reliable speech start/end detection
- **Configurable parameters**: Window size, ratio, VAD aggressiveness
- **Timing information**: Precise speech start/end timestamps

### PortAudio Integration
Audio device support now uses PortAudio instead of the removed SphinxAD library:

- **Cross-platform support**: Works on Linux (ALSA), macOS (CoreAudio), Windows (DirectSound/WASAPI)
- **Blocking audio reads**: More reliable frame-based audio capture
- **Better error handling**: Improved audio device error reporting

### Frame-based Architecture
All audio processing now uses consistent frame sizes:

- **Fixed frame size**: 480 samples (30ms at 16kHz) by default
- **Aligned processing**: Audio device, endpointer, and decoder use same frame size
- **Reduced latency**: More efficient processing pipeline

## Troubleshooting

### Audio Issues
If you encounter audio problems:

1. **Check microphone permissions**: Ensure your application can access the microphone
2. **Test PortAudio**: Try `speaker-test` or other audio tools to verify device access
3. **Check ALSA configuration**: The ALSA warnings in output are normal and can be ignored

### Recognition Issues
If recognition isn't working:

1. **Verify PocketSphinx v5**: Ensure you have v5 installed, not the older v0.8
2. **Check acoustic models**: Make sure PocketSphinx can find its acoustic models
3. **Test with file input**: Try `decode_audio_file.rb` first to verify basic functionality

### Performance Issues
For better performance:

1. **Use appropriate VAD settings**: Adjust endpointer parameters for your environment
2. **Monitor CPU usage**: Real-time recognition can be CPU intensive
3. **Consider frame size**: Larger frames may improve performance but increase latency

## API Migration from v0.8

The high-level API (`LiveSpeechRecognizer`, `Configuration`) remains largely the same, but the underlying implementation has changed:

- **Endpointer replaces VAD**: `in_speech?` now uses endpointer instead of `ps_get_in_speech()`
- **Frame-based processing**: Audio processing uses endpointer frame sizes
- **PortAudio instead of SphinxAD**: New audio device implementation

For most users, simply updating the gem and PocketSphinx version should be sufficient.