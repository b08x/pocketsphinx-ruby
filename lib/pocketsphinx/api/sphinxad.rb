require 'ffi-portaudio'

module Pocketsphinx
  module API
    module SphinxAD
      extend FFI::Library
      
      # PortAudio-based implementation to replace SphinxAD for PocketSphinx v5
      # Uses ffi-portaudio for cross-platform audio device support
      
      class AudioDevice
        attr_reader :stream, :sample_rate, :recording
        
        def initialize(sample_rate)
          @sample_rate = sample_rate
          @recording = false
          @stream = nil
          @frames_per_buffer = 1024
        end
        
        def start_recording
          return -1 if @recording
          
          begin
            # Open default input stream
            input_parameters = FFI::PortAudio::API::PaStreamParameters.new
            input_parameters[:device] = FFI::PortAudio::API.Pa_GetDefaultInputDevice
            input_parameters[:channelCount] = 1
            input_parameters[:sampleFormat] = 0x00000008  # paInt16
            input_parameters[:suggestedLatency] = 0.2
            
            stream_ptr = FFI::MemoryPointer.new(:pointer)
            
            result = FFI::PortAudio::API.Pa_OpenStream(
              stream_ptr,
              input_parameters,
              nil,  # no output
              @sample_rate,
              @frames_per_buffer,
              0,  # no flags
              nil, # no callback
              nil  # no user data
            )
            
            if result == :paNoError
              @stream = stream_ptr.read_pointer
              result = FFI::PortAudio::API.Pa_StartStream(@stream)
              if result == :paNoError
                @recording = true
                return 0
              end
            end
            
            puts "Error starting audio recording: #{FFI::PortAudio::API.Pa_GetErrorText(result)}"
            -1
          rescue => e
            puts "Error starting audio recording: #{e.message}"
            -1
          end
        end
        
        def stop_recording
          return -1 unless @recording
          
          begin
            result = FFI::PortAudio::API.Pa_StopStream(@stream) if @stream
            @recording = false
            result == :paNoError ? 0 : -1
          rescue => e
            puts "Error stopping audio recording: #{e.message}"
            -1
          end
        end
        
        def read_audio(buffer, max_samples)
          return -1 unless @recording && @stream
          
          begin
            # For frame-based processing, read exactly the requested number of samples
            # This aligns with endpointer frame requirements
            result = FFI::PortAudio::API.Pa_ReadStream(@stream, buffer, max_samples)
            
            if result == :paNoError
              max_samples
            else
              # Check if it's just no data available (not an error for non-blocking)
              if result.to_s.include?('Input overflowed') || result.to_s.include?('Stream is not active')
                0
              else
                puts "Error reading audio: #{FFI::PortAudio::API.Pa_GetErrorText(result)}"
                -1
              end
            end
          rescue => e
            puts "Error reading audio: #{e.message}"
            -1
          end
        end
        
        def close
          begin
            FFI::PortAudio::API.Pa_StopStream(@stream) if @stream && @recording
            FFI::PortAudio::API.Pa_CloseStream(@stream) if @stream
            @stream = nil
            @recording = false
          rescue => e
            puts "Error closing audio device: #{e.message}"
          end
        end
      end
      
      def self.ad_open_dev(device, sample_rate)
        begin
          # Initialize PortAudio (paNoError means success)
          result = FFI::PortAudio::API.Pa_Initialize
          if result != :paNoError
            puts "Error initializing PortAudio: #{FFI::PortAudio::API.Pa_GetErrorText(result)}"
            return nil
          end
          
          # Create and return a new audio device
          AudioDevice.new(sample_rate)
        rescue => e
          puts "Error opening audio device: #{e.message}"
          nil
        end
      end
      
      def self.ad_start_rec(ad)
        return -1 unless ad.is_a?(AudioDevice)
        ad.start_recording
      end
      
      def self.ad_stop_rec(ad)
        return -1 unless ad.is_a?(AudioDevice)
        ad.stop_recording
      end
      
      def self.ad_read(ad, buffer, max_samples)
        return -1 unless ad.is_a?(AudioDevice)
        ad.read_audio(buffer, max_samples)
      end
      
      def self.ad_close(ad)
        return 0 unless ad.is_a?(AudioDevice)
        ad.close
        0
      end
    end
  end
end
