#!/usr/bin/env ruby
#
# Advanced speech recognition example using PocketSphinx v5
# This demonstrates custom configuration, partial results, and
# integration between endpointer and decoder.

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

puts "PocketSphinx v5 Advanced Recognition Demo"
puts "Features: partial results, speech timing, custom endpointer"
puts "Press Ctrl+C to stop"
puts ""

begin
  # Create configuration
  configuration = Configuration.default
  
  # Create custom endpointer with specific parameters
  # window: 0.3s, ratio: 0.9, mode: 0 (least aggressive), sample_rate: 16000, frame_length: 0.03s
  endpointer = Endpointer.new(0.3, 0.9, 0, 16000, 0.03)
  
  puts "Configuration:"
  puts "  Endpointer window: 0.3s (speech detection window)"
  puts "  Endpointer ratio: 0.9 (90% of frames must be speech)"
  puts "  VAD mode: 0 (least aggressive, more permissive)"
  puts "  Frame size: #{endpointer.frame_size} samples"
  puts "  Sample rate: #{endpointer.sample_rate} Hz"
  puts ""
  
  # Create decoder and microphone
  decoder = Decoder.new(configuration)
  microphone = Microphone.new(endpointer.sample_rate)
  
  puts "Starting advanced recognition..."
  puts "You'll see: [PARTIAL] results during speech, [FINAL] results after silence"
  puts ""
  
  # Manual recognition loop for demonstration
  microphone.start_recording
  utterance_active = false
  
  FFI::MemoryPointer.new(:int16, endpointer.frame_size) do |buffer|
    loop do
      # Read audio frame
      sample_count = microphone.read_audio(buffer, endpointer.frame_size)
      
      if sample_count && sample_count > 0
        # Track previous speech state
        prev_in_speech = endpointer.in_speech?
        
        # Process through endpointer
        speech = endpointer.process(buffer)
        
        if speech && !speech.null?
          # Speech detected
          if !prev_in_speech
            # Speech start
            puts "[#{Time.now.strftime('%H:%M:%S.%L')}] Speech detected - starting utterance"
            decoder.start_utterance
            utterance_active = true
          end
          
          # Process speech through decoder
          decoder.process_raw(speech, endpointer.frame_size)
          
          # Get partial hypothesis
          if hypothesis = decoder.hypothesis
            print "\r[PARTIAL] #{hypothesis}"
            $stdout.flush
          end
          
          # Check for speech end
          if !endpointer.in_speech?
            # Speech end
            decoder.end_utterance
            
            if hypothesis = decoder.hypothesis
              puts "\r[FINAL]   #{hypothesis}"
              puts "         Speech duration: #{(endpointer.speech_end - endpointer.speech_start).round(2)}s"
              puts ""
            else
              puts "\r[FINAL]   (no recognition result)"
              puts ""
            end
            
            utterance_active = false
          end
        end
      else
        # No audio available
        sleep 0.01
      end
    end
  end
  
rescue SystemExit, Interrupt
  puts "\n\nAdvanced recognition stopped."
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.first(3).join("\n")
ensure
  if microphone
    microphone.stop_recording
  end
  if decoder && utterance_active
    decoder.end_utterance
  end
end