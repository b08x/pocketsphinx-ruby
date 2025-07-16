module Pocketsphinx
  # Voice Activity Detection and Speech Segmentation
  #
  # The Endpointer class wraps PocketSphinx v5's endpointer functionality for
  # detecting speech vs silence in audio streams. It provides frame-based processing
  # and proper speech segmentation for live recognition.
  class Endpointer
    include API::CallHelpers

    attr_reader :ps_endpointer, :frame_size, :sample_rate
    attr_writer :ps_api

    # Initialize a new endpointer for Voice Activity Detection
    #
    # @param [Float] window Window size in seconds (default: 0.0 for automatic)
    # @param [Float] ratio Ratio of frames needed to trigger start/end decision (default: 0.0 for automatic)
    # @param [Integer] mode VAD mode/aggressiveness (default: 0 for automatic)
    # @param [Integer] sample_rate Sample rate in Hz (default: 0 for automatic, typically 16000)
    # @param [Float] frame_length Frame length in seconds (default: 0.0 for automatic)
    def initialize(window = 0.0, ratio = 0.0, mode = 0, sample_rate = 0, frame_length = 0.0)
      @ps_endpointer = ps_api.ps_endpointer_init(window, ratio, mode, sample_rate, frame_length)
      raise API::Error, "Failed to initialize endpointer" if @ps_endpointer.nil? || @ps_endpointer.null?
      
      # Get VAD from endpointer to access frame info
      @vad = ps_api.ps_endpointer_vad(@ps_endpointer)
      @sample_rate = ps_api.ps_vad_sample_rate(@vad)
      @frame_size = ps_api.ps_vad_frame_size(@vad)
      
      # Ensure that endpointer is closed when object is garbage collected
      ObjectSpace.define_finalizer(self, self.class.finalize(@ps_endpointer))
    end

    def self.finalize(ps_endpointer)
      proc do
        # Skip finalization to avoid double-free issues
        # The user should call close() explicitly if needed
      end
    end

    # Process a frame of audio data
    #
    # @param [FFI::Pointer] frame Audio frame buffer (int16 samples)
    # @return [FFI::Pointer, nil] Speech data if speech detected, nil otherwise
    def process(frame)
      result = ps_api.ps_endpointer_process(@ps_endpointer, frame)
      result.null? ? nil : result
    end

    # Process the end of an audio stream
    #
    # @param [FFI::Pointer] frame Final audio frame buffer
    # @param [Integer] frame_size_samples Number of samples in the frame
    # @param [FFI::MemoryPointer] end_samples_ptr Pointer to store end samples count
    # @return [FFI::Pointer, nil] Speech data if any remaining, nil otherwise  
    def end_stream(frame, frame_size_samples, end_samples_ptr)
      result = ps_api.ps_endpointer_end_stream(@ps_endpointer, frame, frame_size_samples, end_samples_ptr)
      result.null? ? nil : result
    end

    # Check if currently in speech
    #
    # @return [Boolean] True if in speech, false otherwise
    def in_speech?
      ps_api.ps_endpointer_in_speech(@ps_endpointer) != 0
    end

    # Get speech start time
    #
    # @return [Float] Speech start time in seconds
    def speech_start
      ps_api.ps_endpointer_speech_start(@ps_endpointer)
    end

    # Get speech end time  
    #
    # @return [Float] Speech end time in seconds
    def speech_end
      ps_api.ps_endpointer_speech_end(@ps_endpointer)
    end

    # Get number of bytes per frame
    #
    # @return [Integer] Number of bytes per frame (frame_size * 2 for int16)
    def frame_bytes
      @frame_size * 2
    end

    # Close the endpointer and free resources
    def close
      # For now, skip explicit cleanup to avoid segfaults
      # Let Ruby's GC handle it naturally
      @ps_endpointer = nil
    end

    def ps_api
      @ps_api || API::Pocketsphinx
    end
  end
end