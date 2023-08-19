module Pocketsphinx
  module API
    module Sphinxbase
      extend FFI::Library
      ffi_lib "libpocketsphinx"

      class Argument < FFI::Struct
        layout :name, :string,
          :type, :int,
          :deflt, :string,
          :doc, :string
      end

      # TODO: Document on ruby side?
      attach_function :ps_config_init, [:pointer, :pointer, :int32, :pointer, :int], :pointer
      attach_function :ps_config_float, [:pointer, :string], :double
      attach_function :ps_config_set_float, [:pointer, :string, :double], :void
      attach_function :ps_config_int, [:pointer, :string], :int
      attach_function :ps_config_set_int, [:pointer, :string, :int], :void
      attach_function :ps_config_str, [:pointer, :string], :string
      attach_function :ps_config_set_str, [:pointer, :string, :string], :void
      attach_function :err_set_logfile, [:string], :int
      attach_function :err_set_logfp, [:pointer], :void
    end
  end
end
