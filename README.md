# pocketsphinx-ruby

[![Build Status](http://img.shields.io/travis/watsonbox/pocketsphinx-ruby.svg?style=flat)](https://travis-ci.org/watsonbox/pocketsphinx-ruby)
[![Code Climate](http://img.shields.io/codeclimate/github/watsonbox/pocketsphinx-ruby/badges/gpa.svg?style=flat)](https://codeclimate.com/github/watsonbox/pocketsphinx-ruby)
[![Coverage Status](https://img.shields.io/coveralls/watsonbox/pocketsphinx-ruby.svg?style=flat)](https://coveralls.io/r/watsonbox/pocketsphinx-ruby)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg?style=flat)](http://www.rubydoc.info/gems/pocketsphinx-ruby/frames)

This gem provides Ruby [FFI](https://github.com/ffi/ffi) bindings for [Pocketsphinx](https://github.com/cmusphinx/pocketsphinx), a lightweight speech recognition engine, specifically tuned for handheld and mobile devices, though it works equally well on the desktop. Pocketsphinx is part of the [CMU Sphinx](http://cmusphinx.sourceforge.net/) Open Source Toolkit For Speech Recognition.

Pocketsphinx's [SWIG](http://www.swig.org/) interface was initially considered for this gem, but dropped in favor of FFI for many of the reasons outlined [here](https://github.com/ffi/ffi/wiki/Why-use-FFI); most importantly ease of maintenance and JRuby support.

The goal of this project is to make it as easy as possible for the Ruby community to experiment with speech recognition. Please do contribute fixes and enhancements.

## ⚠️ **PocketSphinx v5 Compatibility**

**This version has been updated to work with PocketSphinx v5.0+**, which introduced significant API changes. This is a **breaking change** from previous versions that used PocketSphinx v0.8.

### Key Changes in v5 Support

- **New Configuration System**: Uses `ps_config_t` instead of `cmd_ln_t`
- **Updated FFI Bindings**: All function signatures updated for v5 API
- **Enhanced Memory Management**: Proper cleanup of configuration objects
- **Improved Error Handling**: Better error reporting from the C library
- **Ruby 3.x Support**: Updated gem dependencies for modern Ruby versions

### What This Means

- **Installation**: You must install PocketSphinx v5.0+ from source
- **Configuration**: Some parameter names may have changed
- **Audio Devices**: SphinxAD library replaced with PortAudio for live audio input
- **Core Recognition**: All core speech recognition functionality works perfectly

See the [Installation](#installation) section below for PocketSphinx v5 setup instructions.

## Installation

### Prerequisites

This gem requires **PocketSphinx v5.0+** which must be installed from source. The old v0.8 versions are no longer supported.

### Installing PocketSphinx v5

#### Ubuntu/Debian

```bash
# Install build dependencies
sudo apt-get update
sudo apt-get install cmake build-essential git libportaudio2 libportaudio-dev

# Clone and build PocketSphinx v5
git clone https://github.com/cmusphinx/pocketsphinx.git
cd pocketsphinx
cmake -S . -B build -DBUILD_SHARED_LIBS=ON
cmake --build build
sudo cmake --build build --target install
sudo ldconfig
```

#### Fedora/CentOS/RHEL

```bash
# Install build dependencies
sudo dnf install cmake gcc-c++ make git portaudio portaudio-devel

# Clone and build PocketSphinx v5
git clone https://github.com/cmusphinx/pocketsphinx.git
cd pocketsphinx
cmake -S . -B build -DBUILD_SHARED_LIBS=ON
cmake --build build
sudo cmake --build build --target install
sudo ldconfig
```

#### macOS

```bash
# Install build dependencies
brew install cmake portaudio

# Clone and build PocketSphinx v5
git clone https://github.com/cmusphinx/pocketsphinx.git
cd pocketsphinx
cmake -S . -B build -DBUILD_SHARED_LIBS=ON
cmake --build build
sudo cmake --build build --target install
```

#### Verify Installation

```bash
# Test that PocketSphinx v5 is working
pocketsphinx -h
```

### Installing the Ruby Gem

Then add this line to your application's Gemfile:

    gem 'pocketsphinx-ruby'

And then execute:

    bundle

Or install it yourself as:

    gem install pocketsphinx-ruby

### Audio Device Prerequisites

For live audio input functionality (microphone support), you'll need to install PortAudio:

#### Ubuntu/Debian

```bash
sudo apt-get install libportaudio2 libportaudio-dev
```

#### Fedora/CentOS/RHEL

```bash
sudo dnf install portaudio portaudio-devel
```

#### macOS

```bash
brew install portaudio
```

The `ffi-portaudio` gem dependency will be automatically installed when you install `pocketsphinx-ruby`.

## Usage

The `LiveSpeechRecognizer` is modeled on the same class in [Sphinx4](http://cmusphinx.sourceforge.net/wiki/tutorialsphinx4). It uses the `Microphone` and `Decoder` classes internally to provide a simple, high-level recognition interface:

```ruby
require 'pocketsphinx-ruby' # Omitted in subsequent examples

Pocketsphinx::LiveSpeechRecognizer.new.recognize do |speech|
  puts speech
end
```

The `AudioFileSpeechRecognizer` decodes directly from an audio file by coordinating interactions between an `AudioFile` and `Decoder`.

```ruby
recognizer = Pocketsphinx::AudioFileSpeechRecognizer.new

recognizer.recognize('spec/assets/audio/goforward.raw') do |speech|
  puts speech # => "go forward ten meters"
end
```

These two classes split speech into utterances by detecting silence between them. By default this uses Pocketsphinx's internal Voice Activity Detection (VAD) which can be configured by adjusting the `vad_postspeech`, `vad_prespeech`, and `vad_threshold` configuration settings.

### Configuration

All of Pocketsphinx's decoding settings are managed by the `Configuration` class, which can be passed into the high-level speech recognizers:

```ruby
configuration = Pocketsphinx::Configuration.default
configuration.details('vad_threshold')
# => {
#   :name => "vad_threshold",
#   :type => :float,
#   :default => 2.0,
#   :value => 2.0,
#   :info => "Threshold for decision between noise and silence frames. Log-ratio between signal level and noise level."
# }

configuration['vad_threshold'] = 4

Pocketsphinx::LiveSpeechRecognizer.new(configuration)
```

You can find the output of `configuration.details` [here](https://github.com/watsonbox/pocketsphinx-ruby/wiki/Default-Pocketsphinx-Configuration) for more information on the various different settings.

### Microphone

The `Microphone` class uses PortAudio (via the `ffi-portaudio` gem) to record audio for speech recognition. For desktop applications this should normally be 16bit/16kHz raw PCM audio, so these are the default settings. PortAudio provides cross-platform audio support for Linux (ALSA), macOS (CoreAudio), and Windows (DirectSound/WASAPI).

**Note**: PocketSphinx v5 removed the SphinxAD library, so this gem now uses PortAudio as a replacement for live audio input functionality.

For example, to record and save a 5 second raw audio file:

```ruby
microphone = Pocketsphinx::Microphone.new

File.open("test.raw", "wb") do |file|
  microphone.record do
    FFI::MemoryPointer.new(:int16, 2048) do |buffer|
      50.times do
        sample_count = microphone.read_audio(buffer, 2048)
        file.write buffer.get_bytes(0, sample_count * 2)

        sleep 0.1
      end
    end
  end
end
```

To open this audio file take a look at [this wiki page](https://github.com/watsonbox/pocketsphinx-ruby/wiki/Importing-raw-PCM-audio-with-Audacity).

### Decoder

The `Decoder` class uses Pocketsphinx's libpocketsphinx to decode audio data into text. For example to decode a single utterance:

```ruby
decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
decoder.decode 'spec/assets/audio/goforward.raw'

puts decoder.hypothesis # => "go forward ten meters"
```

And split into individual words with frame data:

```ruby
decoder.words
# => [
#  #<struct Pocketsphinx::Decoder::Word word="<s>", start_frame=608, end_frame=610>,
#  #<struct Pocketsphinx::Decoder::Word word="go", start_frame=611, end_frame=622>,
#  #<struct Pocketsphinx::Decoder::Word word="forward", start_frame=623, end_frame=675>,
#  #<struct Pocketsphinx::Decoder::Word word="ten", start_frame=676, end_frame=711>,
#  #<struct Pocketsphinx::Decoder::Word word="meters", start_frame=712, end_frame=770>,
#  #<struct Pocketsphinx::Decoder::Word word="</s>", start_frame=771, end_frame=821>
# ]
```

Note: When the `Decoder` is initialized, the supplied `Configuration` is updated by Pocketsphinx with some settings from the acoustic model. To see exactly what's going on:

```ruby
Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default).configuration.changes
```

### Keyword Spotting

Keyword spotting is another feature that is not in the current stable (0.8) releases of Pocketsphinx, having been [merged into trunk](https://github.com/cmusphinx/pocketsphinx/commit/f562f9356cc7f1ade4941ebdde0c377642a023e3) early in 2014. It can be useful for detecting an activation keyword in a command and control application, while ignoring all other speech. Set up a recognizer as follows:

```ruby
configuration = Pocketsphinx::Configuration::KeywordSpotting.new('Okay computer')
recognizer = Pocketsphinx::LiveSpeechRecognizer.new(configuration)
```

The `KeywordSpotting` configuration accepts a second argument for adjusting the sensitivity of the keyword detection. Note that this is just a wrapper which sets the `keyphrase` and `kws_threshold` settings on the default configuration, and removes the language model:

```ruby
Pocketsphinx::Configuration::KeywordSpotting.new('keyword', 2).changes
# => [
#   { :name => "keyphrase", :type => :string, :default => nil, :required => false, :value => "keyword", :info => "Keyphrase to spot" },
#   { :name => "kws_threshold", :type => :float, :default => 1.0, :required => false, :value => 2.0, :info => "Threshold for p(hyp)/p(alternatives) ratio" },
#   { :name => "lm", :type => :string, :default => "/usr/local/Cellar/cmu-pocketsphinx/HEAD/share/pocketsphinx/model/lm/en_US/hub4.5000.DMP", :required => false, :value => nil, :info => "Word trigram language model input file" }
# ]
```

### Grammars

Another way of configuring Pocketsphinx is with a grammar, which is normally used to describe very simple types of languages for command and control. Restricting the set of possible utterances in this way can greatly improve recognition accuracy for these types of application.

Load a [JSGF](http://www.w3.org/TR/jsgf/) grammar from a file:

```ruby
configuration = Pocketsphinx::Configuration::Grammar.new('sentences.gram')
```

Or build one dynamically with this simple DSL (currently only supports sentence lists):

```ruby
configuration = Pocketsphinx::Configuration::Grammar.new do
  sentence "Go forward ten meters"
  sentence "Go backward ten meters"
end
```

## Recognition Accuracy and Training

See the CMU Sphinx resources on [training](http://cmusphinx.sourceforge.net/wiki/tutorialam) and [adapting](http://cmusphinx.sourceforge.net/wiki/tutorialadapt) acoustic models for more information.

[Peter Grasch](http://grasch.net/), author of [Simon](https://simon.kde.org/), has also made a number of interesting posts on the [state of open source speech recognition](http://grasch.net/node/19), as wells as improving [language](http://grasch.net/node/20) and [acoustic](http://grasch.net/node/21) models.

See [`sphinxtrain-ruby`](https://github.com/watsonbox/sphinxtrain-ruby) for an experimental toolkit for training/adapting CMU Sphinx acoustic models. Its main goal is to help with adapting existing acoustic models to a specific speaker/accent.

## Migration from v0.8 to v5

### Breaking Changes

**Configuration API Changes:**

- Parameter names no longer require `-` prefix in Ruby code
- Some parameters have been renamed or removed in PocketSphinx v5
- Configuration objects now use `ps_config_t` instead of `cmd_ln_t`

**Audio Device Changes:**

- SphinxAD library is no longer available in PocketSphinx v5
- Live audio input now uses PortAudio instead of SphinxAD
- Requires PortAudio system dependency for microphone functionality
- File-based audio processing works normally

**Dependency Changes:**

- Now requires Ruby 3.0+ (updated from earlier versions)
- FFI dependency updated to 1.15+ (from 1.9+)
- Modern RSpec and other development dependencies

### Code Migration Examples

**Before (v0.8):**

```ruby
# Old configuration parameter access
config['-samprate'] = 16000
config['-vad_threshold'] = 3.0

# Old dependencies in Gemfile
gem 'pocketsphinx-ruby', '~> 0.3'
```

**After (v5):**

```ruby
# New configuration parameter access
config['samprate'] = 16000
# Note: vad_threshold may not be available in v5

# New dependencies in Gemfile
gem 'pocketsphinx-ruby', '~> 5.0'
```

## Troubleshooting

### Common Issues

**Library not found errors:**

```
Could not open library 'libpocketsphinx'
```

- Ensure PocketSphinx v5 is installed with shared libraries (`-DBUILD_SHARED_LIBS=ON`)
- Run `sudo ldconfig` after installation
- Check that `/usr/local/lib64/libpocketsphinx.so` exists

**Function not found errors:**

```
Function 'ps_config_init' not found
```

- This indicates an old version of PocketSphinx is installed
- Uninstall old versions and install PocketSphinx v5 from source

**Parameter not found errors:**

```
Configuration setting 'vad_threshold' does not exist
```

- Some parameters have been renamed or removed in v5
- Check available parameters with `config.setting_names`
- Consult PocketSphinx v5 documentation for current parameter names

**Ruby version compatibility:**

```
undefined method `untaint'
```

- This gem now requires Ruby 3.0+
- Update your Ruby version or use an older version of this gem

### Getting Help

This gem has been tested with PocketSphinx v5 on:

- Ubuntu 20.04+ with Ruby 3.0+
- Fedora 35+ with Ruby 3.0+
- macOS 12+ with Ruby 3.0+

For issues, please include:

- Your operating system and version
- Ruby version (`ruby -v`)
- PocketSphinx version (`pocketsphinx -h`)
- Complete error messages

## Contributing

1. Fork it ( <https://github.com/watsonbox/pocketsphinx-ruby/fork> )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Projects Using pocketsphinx-ruby

- [Isabella](https://github.com/chrisvfritz/isabella) - A voice-computing assistant built in Ruby.
- [sphinxtrain-ruby](https://github.com/watsonbox/sphinxtrain-ruby) - A Toolkit for training/adapting CMU Sphinx acoustic models.
