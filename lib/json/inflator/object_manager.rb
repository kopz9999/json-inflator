module Json
  module Inflator
    class ObjectManager

      # Modules
      module Keys
        Current = :current_inflator_manager
      end

      module ClassMethods

        def current_instance
          Thread.current[ Keys::Current ]
        end

        def current_instance=(value)
          Thread.current[ Keys::Current ] = value
        end

      end

      # Mixins
      extend ClassMethods

      # Attribute Definition
      public
      # Settings
      attr_accessor :settings
      # Storing references
      attr_accessor :object_tracker

      # Current Path. Only for JPath
      attr_accessor :current_path

      def initialize( opts = {} )
        settings_value = opts[:settings]
        self.settings = settings_value.nil? ? 
          Json::Inflator.default_settings : Inflator::Settings.new(settings_value)
        self.object_tracker = Hash.new
        case self.settings.mode
          when Json::Inflator::Modes::JPath
            self.current_path = self.settings.root_symbol
        end
      end

    end
  end
end