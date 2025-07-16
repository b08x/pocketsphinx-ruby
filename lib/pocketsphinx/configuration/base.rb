module Pocketsphinx
  module Configuration
    class Base
      attr_reader :ps_config
      attr_reader :setting_definitions

      def initialize
        @ps_arg_defs = API::Pocketsphinx.ps_args
        @setting_definitions = SettingDefinition.from_arg_defs(@ps_arg_defs)

        # Create new ps_config_t object using the v5 API
        @ps_config = API::Pocketsphinx.ps_config_init(nil)
        
        # Set up finalizer to free the ps_config_t object when Ruby object is garbage collected
        ObjectSpace.define_finalizer(self, self.class.finalize(@ps_config))
      end

      def self.finalize(ps_config)
        proc { API::Pocketsphinx.ps_config_free(ps_config) if ps_config }
      end

      def setting_names
        setting_definitions.keys.sort
      end

      # Get details for one or all configuration settings
      #
      # @param [String] name Name of setting to get details for. Gets details for all settings if nil.
      def details(name = nil)
        details = [name || setting_names].flatten.map do |name|
          definition = find_definition(name)

          {
            name: name,
            type: definition.type,
            default: definition.default,
            required: definition.required?,
            value: self[name],
            info: definition.doc
          }
        end

        name ? details.first : details
      end

      # Get a configuration setting
      def [](name)
        case find_definition(name).type
        when :integer
          API::Pocketsphinx.ps_config_int(ps_config, name)
        when :float
          API::Pocketsphinx.ps_config_float(ps_config, name)
        when :string
          API::Pocketsphinx.ps_config_str(ps_config, name)
        when :boolean
          API::Pocketsphinx.ps_config_bool(ps_config, name) != 0
        when :string_list
          raise NotImplementedError
        end
      end

      # Set a configuration setting with type checking
      def []=(name, value)
        check_type(name, type = find_definition(name).type, value)

        case type
        when :integer
          API::Pocketsphinx.ps_config_set_int(ps_config, name, value.to_i)
        when :float
          API::Pocketsphinx.ps_config_set_float(ps_config, name, value.to_f)
        when :string
          API::Pocketsphinx.ps_config_set_str(ps_config, name, (value.to_s if value))
        when :boolean
          API::Pocketsphinx.ps_config_set_bool(ps_config, name, value ? 1 : 0)
        when :string_list
          raise NotImplementedError
        end
      end

      # Get the parameter type for a setting
      def typeof(name)
        API::Pocketsphinx.ps_config_typeof(ps_config, name)
      end

      # Validate the configuration
      def validate
        result = API::Pocketsphinx.ps_config_validate(ps_config)
        result == 0
      end

      # Serialize configuration to JSON
      def to_json
        API::Pocketsphinx.ps_config_serialize_json(ps_config)
      end

      # Parse JSON configuration
      def self.from_json(json)
        config = new
        config.instance_variable_set(:@ps_config, API::Pocketsphinx.ps_config_parse_json(nil, json))
        config
      end

      private

      def find_definition(name)
        setting_definitions[name] or raise "Configuration setting '#{name}' does not exist"
      end

      def check_type(name, expected_type, value)
        conversion_method = case expected_type
          when :integer then :to_i
          when :float then :to_f
        end

        if conversion_method && !value.respond_to?(conversion_method)
          raise "Configuration setting '#{name}' must be of type #{expected_type.to_s.capitalize}"
        end

        if value.nil? && expected_type != :string
          raise "Only string settings can be set to nil"
        end
      end
    end
  end
end
