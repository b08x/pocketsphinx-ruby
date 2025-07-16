#!/usr/bin/env ruby
#
# Record audio to a file using PocketSphinx v5 with PortAudio
# This example demonstrates frame-based audio recording that aligns
# with the endpointer frame requirements.

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

RECORDING_LENGTH = 5

puts "Recording #{RECORDING_LENGTH} seconds of audio using PocketSphinx v5..."

begin
  # Create endpointer to get proper frame size
  endpointer = Endpointer.new
  frame_size = endpointer.frame_size
  sample_rate = endpointer.sample_rate
  
  puts "Frame size: #{frame_size} samples"
  puts "Sample rate: #{sample_rate} Hz" 
  puts "Frame duration: #{frame_size.to_f / sample_rate} seconds"
  
  # Create microphone with matching sample rate
  microphone = Microphone.new(sample_rate)
  
  # Calculate number of frames needed for desired recording length
  frames_needed = (RECORDING_LENGTH * sample_rate / frame_size).to_i
  puts "Recording #{frames_needed} frames..."
  
  File.open("test_write.raw", "wb") do |file|
    microphone.record do
      FFI::MemoryPointer.new(:int16, frame_size) do |buffer|
        frames_needed.times do |frame_num|
          sample_count = microphone.read_audio(buffer, frame_size)
          
          if sample_count && sample_count > 0
            # Write frame to file (sample_count * 2 since int16 = 2 bytes)
            file.write buffer.get_bytes(0, sample_count * 2)
            print "." if frame_num % 10 == 0  # Progress indicator
          else
            # Handle case where no audio is available
            sleep 0.01
          end
        end
      end
    end
  end
  
  puts "\nRecording completed! Saved to test_write.raw"
  puts "To play with audacity: Import as Raw Data, Signed 16-bit PCM, #{sample_rate} Hz, Mono"
  
rescue => e
  puts "Error: #{e.message}"
  puts "Make sure you have:"
  puts "1. A working microphone"
  puts "2. PortAudio installed (libportaudio2-dev)"
  puts "3. Proper permissions for audio device access"
end
