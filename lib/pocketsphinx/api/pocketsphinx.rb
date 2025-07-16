module Pocketsphinx
  module API
    module Pocketsphinx
      extend FFI::Library
      ffi_lib "libpocketsphinx"

      typedef :pointer, :decoder
      typedef :pointer, :configuration
      typedef :pointer, :logmath
      typedef :pointer, :seg_iter
      typedef :pointer, :nbest_iter
      typedef :pointer, :lattice

      # Configuration object functions
      attach_function :ps_config_init, [:pointer], :configuration
      attach_function :ps_config_retain, [:configuration], :configuration
      attach_function :ps_config_free, [:configuration], :int
      attach_function :ps_config_validate, [:configuration], :int
      attach_function :ps_config_parse_json, [:configuration, :string], :configuration
      attach_function :ps_config_serialize_json, [:configuration], :string
      attach_function :ps_config_typeof, [:configuration, :string], :int
      attach_function :ps_config_get, [:configuration, :string], :pointer
      attach_function :ps_config_set, [:configuration, :string, :pointer, :int], :pointer
      attach_function :ps_config_int, [:configuration, :string], :long
      attach_function :ps_config_bool, [:configuration, :string], :int
      attach_function :ps_config_float, [:configuration, :string], :double
      attach_function :ps_config_str, [:configuration, :string], :string
      attach_function :ps_config_set_int, [:configuration, :string, :long], :pointer
      attach_function :ps_config_set_bool, [:configuration, :string, :int], :pointer
      attach_function :ps_config_set_float, [:configuration, :string, :double], :pointer
      attach_function :ps_config_set_str, [:configuration, :string, :string], :pointer
      attach_function :ps_config_soundfile, [:configuration, :pointer, :string], :int
      attach_function :ps_config_wavfile, [:configuration, :pointer, :string], :int
      attach_function :ps_config_nistfile, [:configuration, :pointer, :string], :int
      attach_function :ps_default_search_args, [:configuration], :void
      attach_function :ps_expand_model_config, [:configuration], :void
      attach_function :ps_default_modeldir, [], :string

      # Decoder functions
      attach_function :ps_init, [:configuration], :decoder
      attach_function :ps_reinit, [:decoder, :configuration], :int
      attach_function :ps_reinit_feat, [:decoder, :configuration], :int
      attach_function :ps_get_cmn, [:decoder, :int], :string
      attach_function :ps_set_cmn, [:decoder, :string], :int
      attach_function :ps_args, [], :pointer
      attach_function :ps_retain, [:decoder], :decoder
      attach_function :ps_free, [:decoder], :int
      attach_function :ps_get_config, [:decoder], :configuration
      attach_function :ps_get_logmath, [:decoder], :logmath
      attach_function :ps_update_mllr, [:decoder, :pointer], :pointer
      attach_function :ps_load_dict, [:decoder, :string, :string, :string], :int
      attach_function :ps_save_dict, [:decoder, :string, :string], :int
      attach_function :ps_add_word, [:decoder, :string, :string, :int], :int
      attach_function :ps_lookup_word, [:decoder, :string], :string

      # Audio processing functions
      attach_function :ps_decode_raw, [:decoder, :pointer, :long], :long
      attach_function :ps_decode_senscr, [:decoder, :pointer], :int
      attach_function :ps_start_stream, [:decoder], :int
      attach_function :ps_get_in_speech, [:decoder], :int
      attach_function :ps_start_utt, [:decoder], :int
      attach_function :ps_process_raw, [:decoder, :pointer, :size_t, :int, :int], :int
      attach_function :ps_process_cep, [:decoder, :pointer, :int, :int, :int], :int
      attach_function :ps_get_n_frames, [:decoder], :int
      attach_function :ps_end_utt, [:decoder], :int

      # Recognition results
      attach_function :ps_get_hyp, [:decoder, :pointer], :string
      attach_function :ps_get_prob, [:decoder], :int32
      attach_function :ps_get_lattice, [:decoder], :lattice

      # Segmentation iterator
      attach_function :ps_seg_iter, [:decoder], :seg_iter
      attach_function :ps_seg_next, [:seg_iter], :seg_iter
      attach_function :ps_seg_word, [:seg_iter], :string
      attach_function :ps_seg_frames, [:seg_iter, :pointer, :pointer], :void
      attach_function :ps_seg_prob, [:seg_iter, :pointer, :pointer, :pointer], :int32
      attach_function :ps_seg_free, [:seg_iter], :void

      # N-best iterator
      attach_function :ps_nbest, [:decoder], :nbest_iter
      attach_function :ps_nbest_next, [:nbest_iter], :nbest_iter
      attach_function :ps_nbest_hyp, [:nbest_iter, :pointer], :string
      attach_function :ps_nbest_seg, [:nbest_iter], :seg_iter
      attach_function :ps_nbest_free, [:nbest_iter], :void

      # Performance statistics
      attach_function :ps_get_utt_time, [:decoder, :pointer, :pointer, :pointer], :void
      attach_function :ps_get_all_time, [:decoder, :pointer, :pointer, :pointer], :void

      # Error reporting - Note: ps_get_pub_err_msg not available in v5

      # Math functions
      attach_function :logmath_exp, [:logmath, :int], :double

      # Search module functions (for compatibility)
      attach_function :ps_add_jsgf_string, [:decoder, :string, :string], :int
      attach_function :ps_remove_search, [:decoder, :string], :int
      attach_function :ps_current_search, [:decoder], :string
      attach_function :ps_activate_search, [:decoder, :string], :int

      # Allows expect(API::Pocketsphinx).to receive(:ps_init) in JRuby specs
      def self.ps_init(*args)
        ps_init_private(*args)
      end

      attach_function :ps_init_private, :ps_init, [:configuration], :decoder
    end
  end
end
