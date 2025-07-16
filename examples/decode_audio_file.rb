#!/usr/bin/env ruby
#
# Decode audio from a file using PocketSphinx v5
# This example shows basic file-based speech recognition.
# File-based decoding works the same in v5 as in previous versions.

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

puts "Decoding audio file with PocketSphinx v5..."

begin
  # Create decoder with default configuration
  decoder = Decoder.new(Configuration.default)
  
  # Decode the sample audio file
  audio_file = 'spec/assets/audio/goforward.raw'
  
  if File.exist?(audio_file)
    decoder.decode(audio_file)
    
    # Get the recognition result
    hypothesis = decoder.hypothesis
    puts "Recognized: #{hypothesis}"
    
    # Show word-level timing information
    puts "\nWord-level breakdown:"
    decoder.words.each do |word|
      puts "  #{word.word} (frames #{word.start_frame}-#{word.end_frame})"
    end
  else
    puts "Audio file not found: #{audio_file}"
    puts "Please run this from the pocketsphinx-ruby root directory."
  end
  
rescue => e
  puts "Error: #{e.message}"
  puts "Make sure PocketSphinx v5 is properly installed."
end