module Pocketsphinx
  # Reads audio data from a recordable interface and decodes it into utterances
  #
  # Essentially orchestrates interaction between Recordable and Decoder, and detects new utterances.
  class SpeechRecognizer
    # Recordable interface must implement #start_recording, #stop_recording and #read_audio
    attr_writer :recordable
    attr_writer :decoder
    attr_writer :configuration
    attr_writer :endpointer

    ALGORITHMS = [:after_speech, :continuous]

    def initialize(configuration = nil)
      @configuration = configuration
    end

    def recordable
      @recordable or raise "A SpeechRecognizer must have a recordable interface"
    end

    def decoder
      @decoder ||= Decoder.new(configuration)
    end

    def configuration
      @configuration ||= Configuration.default
    end

    def endpointer
      @endpointer ||= Endpointer.new
    end

    # Reinitialize the decoder with updated configuration.
    #
    # See Decoder#reconfigure
    #
    # @param [Configuration] configuration An optional new configuration to use.  If this is
    #   nil, the previous configuration will be reloaded, with any changes applied.
    def reconfigure(configuration = nil)
      self.configuration = configuration if configuration

      pause do
        decoder.reconfigure(configuration)
      end
    end

    # Recognize speech and yield hypotheses in infinite loop
    #
    # @param [Fixnum] max_samples Number of samples to process at a time (ignored, uses endpointer frame size)
    def recognize(max_samples = nil, &b)
      unless ALGORITHMS.include?(algorithm)
        raise NotImplementedError, "Unknown speech recognition algorithm: #{algorithm}"
      end

      start unless recognizing?

      # Use endpointer frame size for proper VAD processing
      frame_size = endpointer.frame_size
      FFI::MemoryPointer.new(:int16, frame_size) do |buffer|
        loop do
          send("recognize_#{algorithm}", frame_size, buffer, &b) or break
        end
      end
    ensure
      stop
    end

    def in_speech?
      # Use endpointer for Voice Activity Detection in v5
      endpointer.in_speech?
    end

    def recognizing?
      @recognizing == true
    end

    def pause
      recognizing?.tap do |was_recognizing|
        stop if was_recognizing
        yield
        start if was_recognizing
      end
    end

    def start
      recordable.start_recording
      @recognizing = true
    end

    def stop
      recordable.stop_recording
      @recognizing = false
    end

    # Determine which algorithm to use for co-ordinating speech recognition
    #
    # @return [Symbol] :continuous or :after_speech
    # :continuous yields as soon as any hypothesis is available
    # :after_speech yields hypothesis on speech -> silence transition if one exists
    # Default is :after_speech
    def algorithm
      if configuration.respond_to?(:recognition_algorithm)
        configuration.recognition_algorithm
      else
        ALGORITHMS.first
      end
    end

    private

    # Yields as soon as any hypothesis is available
    def recognize_continuous(frame_size, buffer)
      # Read a frame of audio data
      return false unless read_frame(buffer, frame_size)
      
      # Track previous speech state for start/end detection
      prev_in_speech = endpointer.in_speech?
      
      # Process frame through endpointer for VAD
      speech = endpointer.process(buffer)
      
      if speech && !speech.null?
        # Speech detected - start utterance if we weren't in speech before
        if !prev_in_speech
          decoder.start_utterance
        end
        
        # Process speech data through decoder
        decoder.process_raw(speech, frame_size)
        
        # Yield hypothesis immediately if available (continuous mode)
        if hypothesis = decoder.hypothesis
          yield hypothesis
        end
        
        # Reset for next utterance in continuous mode
        if !endpointer.in_speech?
          decoder.end_utterance
        end
      end
      
      true
    end

    # Splits speech into utterances by detecting silence between them.
    # Uses PocketSphinx v5's endpointer for Voice Activity Detection (VAD).
    def recognize_after_speech(frame_size, buffer)
      # Read a frame of audio data
      return false unless read_frame(buffer, frame_size)
      
      # Track previous speech state for start/end detection
      prev_in_speech = endpointer.in_speech?
      
      # Process frame through endpointer for VAD
      speech = endpointer.process(buffer)
      
      if speech && !speech.null?
        # Speech detected - start utterance if we weren't in speech before
        if !prev_in_speech
          puts "Speech start at %.2f" % endpointer.speech_start if $DEBUG
          decoder.start_utterance
        end
        
        # Process speech data through decoder
        decoder.process_raw(speech, frame_size)
        
        # Get partial hypothesis
        if hypothesis = decoder.hypothesis
          puts "PARTIAL: #{hypothesis}" if $DEBUG
        end
        
        # Check if speech ended
        if !endpointer.in_speech?
          puts "Speech end at %.2f" % endpointer.speech_end if $DEBUG
          decoder.end_utterance
          
          # Yield final hypothesis if available
          if hypothesis = decoder.hypothesis
            yield hypothesis
          end
        end
      end
      
      true
    end

    # Read a frame of audio data from the recordable interface
    #
    # @param [FFI::Pointer] buffer Buffer to read audio data into
    # @param [Integer] frame_size Number of samples to read
    # @return [Boolean] True if frame was read successfully, false otherwise
    def read_frame(buffer, frame_size)
      sample_count = recordable.read_audio(buffer, frame_size)
      
      if sample_count && sample_count > 0
        # Check for a delay for example in case of non-blocking live audio
        if recordable.respond_to?(:read_audio_delay)
          sleep recordable.read_audio_delay(frame_size)
        end
        true
      else
        false
      end
    end
  end
end
