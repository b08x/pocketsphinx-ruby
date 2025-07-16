#!/usr/bin/env ruby
#
# Voice Activity Detection (VAD) demonstration using PocketSphinx v5 Endpointer
# This example shows how to use the endpointer for speech detection without
# running full speech recognition.

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

puts "PocketSphinx v5 Endpointer (VAD) Demo"
puts "This demonstrates voice activity detection without recognition"
puts "Press Ctrl+C to stop"
puts ""

begin
  # Create endpointer for Voice Activity Detection
  endpointer = Endpointer.new
  
  puts "Endpointer initialized:"
  puts "  Frame size: #{endpointer.frame_size} samples"
  puts "  Sample rate: #{endpointer.sample_rate} Hz"
  puts "  Frame duration: #{endpointer.frame_size.to_f / endpointer.sample_rate} seconds"
  puts ""
  
  # Create microphone with matching sample rate
  microphone = Microphone.new(endpointer.sample_rate)
  
  puts "Listening for speech... (speak into your microphone)"
  puts "Speech periods will be detected and marked"
  puts ""
  
  # Start recording and processing
  microphone.start_recording
  
  FFI::MemoryPointer.new(:int16, endpointer.frame_size) do |buffer|
    frame_count = 0
    
    loop do
      # Read a frame of audio
      sample_count = microphone.read_audio(buffer, endpointer.frame_size)
      
      if sample_count && sample_count > 0
        frame_count += 1
        
        # Track previous speech state
        prev_in_speech = endpointer.in_speech?
        
        # Process frame through endpointer
        speech = endpointer.process(buffer)
        
        # Check for speech state changes
        if !prev_in_speech && endpointer.in_speech?
          puts "[#{Time.now.strftime('%H:%M:%S')}] Speech START (frame #{frame_count})"
          puts "  Speech start time: #{endpointer.speech_start.round(2)}s"
        elsif prev_in_speech && !endpointer.in_speech?
          puts "[#{Time.now.strftime('%H:%M:%S')}] Speech END (frame #{frame_count})"
          puts "  Speech end time: #{endpointer.speech_end.round(2)}s"
          puts "  Speech duration: #{(endpointer.speech_end - endpointer.speech_start).round(2)}s"
          puts ""
        end
        
        # Show activity indicator
        if endpointer.in_speech?
          print "█" if frame_count % 5 == 0  # Visual indicator during speech
        else
          print "·" if frame_count % 20 == 0  # Quiet indicator
        end
        
        # Flush output
        $stdout.flush
      else
        # No audio available, wait a bit
        sleep 0.01
      end
    end
  end
  
rescue SystemExit, Interrupt
  puts "\n\nEndpointer demo stopped."
  microphone.stop_recording if microphone
rescue => e
  puts "Error: #{e.message}"
  puts "Make sure you have:"
  puts "1. A working microphone"
  puts "2. PortAudio installed (libportaudio2-dev)"
  puts "3. Proper permissions for audio device access"
ensure
  microphone.stop_recording if microphone
end