#!/usr/bin/env ruby
#
# Continuous live speech recognition using PocketSphinx v5
# This example demonstrates real-time speech recognition with proper
# Voice Activity Detection using the new endpointer functionality.

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

puts "PocketSphinx v5 Continuous Speech Recognition"
puts "Press Ctrl+C to stop"
puts ""

begin
  # Create default configuration
  configuration = Configuration.default
  
  # Create live speech recognizer with endpointer-based VAD
  recognizer = LiveSpeechRecognizer.new(configuration)
  
  puts "Initializing microphone and decoder..."
  puts "Endpointer frame size: #{recognizer.endpointer.frame_size} samples"
  puts "Sample rate: #{recognizer.endpointer.sample_rate} Hz"
  puts ""
  puts "Listening... (speak into your microphone)"
  
  # Start continuous recognition
  recognizer.recognize do |speech|
    puts "=> #{speech}"
  end
  
rescue SystemExit, Interrupt
  puts "\nRecognition stopped."
rescue => e
  puts "Error: #{e.message}"
  puts "Make sure you have:"
  puts "1. A working microphone"
  puts "2. PortAudio installed (libportaudio2-dev)"
  puts "3. PocketSphinx v5 properly installed"
end
