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

      # Error logging functions
      attach_function :err_set_logfile, [:string], :int
      attach_function :err_set_logfp, [:pointer], :void
      attach_function :err_set_loglevel, [:int], :void
      
      # Log levels
      ERR_DEBUG = 0
      ERR_INFO = 1
      ERR_WARN = 2
      ERR_ERROR = 3
      ERR_FATAL = 4
    end
  end
end
