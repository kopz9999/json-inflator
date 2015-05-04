module Json
  module Inflator
    module Inflatable

      # @opts =
      #   - :except = array of keys to exclude from object attributes
      #   - :only = array of keys to include from object attributes
      #   - :settings = 
      #     - hash parameters for settings
      def inflate_json!(opts = {})
        if ObjectManager.current_instance.nil?
          # this means that there's no current iteration
          result = Thread.new do
            ObjectManager.current_instance = 
              ObjectManager.new( settings: opts.delete(:settings) )
            self.evaluate_inflate! opts
          end
          result.join
          result.value
        else
          # Keep iterating
          self.evaluate_inflate! opts
        end
      end

      protected

      def evaluate_inflate!( opts = {})
        assert_reference do
          case ObjectManager.current_instance.settings.mode
            when Json::Inflator::Modes::JPath
              return evaluate_inflate_jpath!( opts )
            when Json::Inflator::Modes::StaticReference
              return evaluate_inflate_static_reference!( opts )
          end
        end
      end

      def inflate_jpath!( opts = {} )
        raise NotImplementedError
      end

      def inflate_static_reference!( opts = {} )
        raise NotImplementedError
      end

      private

      # eval_inflate_static_reference!
      def evaluate_inflate_static_reference!( opts = {} )
        if self.is_a?(Hash)
          if self.has_key?(Identities::Values)
            if ObjectManager.current_instance.settings.preserve_arrays?
              return store_reference_array_for_static_reference!(opts)
            else
              raise Error::WrongSettings.new("Arrays are being preserved but "\
                "this is not specified in settings")
            end
          else
            return store_reference_for_static_reference!(opts)
          end
        else
          store_reference_for_static_reference!(opts)
        end
      end

      # Store this one and solve circular references
      def store_reference_array_for_static_reference!( opts = {} )
        reference_key = self[ Identities::Identifier ]
        value_array = self[ Identities::Values ]
        ObjectManager.current_instance.object_tracker[ reference_key ] = 
          value_array
        # Friend method
        value_array.send(:'inflate_static_reference!', opts)
      end

      # Store this one and solve circular references
      def store_reference_for_static_reference!( opts = {} )
        reference_key = self[ Identities::Identifier ]
        ObjectManager.current_instance.object_tracker[ reference_key ] = self
        self.inflate_static_reference!( opts )
      end

      def assert_reference
        if self.is_a?(Hash) && self.has_key?(Identities::Reference)
          object_reference = self[ Identities::Reference ]
          stored_object = ObjectManager.current_instance
            .object_tracker[ object_reference ]
          if stored_object.nil?
            error_message = "$ref=#{object_reference} has not been stored. "\
              'Deflate algorithm is wrong or it is serializing in different order. '\
              'Check if arrays are being preserved'
            raise Error::UndefinedReference.new(error_message)
          end
          stored_object
        else
          yield
        end
      end

      def evaluate_inflate_jpath!( opts = {} )
        if self.is_a?(Array)
          ObjectManager.current_instance.settings.preserve_arrays? ?
            store_reference_for_jpath!(opts) : self.inflate_jpath!( opts )
        else
          # Contrary case is always a Hash
          store_reference_for_jpath!(opts)          
        end
      end

      # Store this one and solve circular references
      # It may overrode to do whatever you want
      def store_reference_for_jpath!(opts)
        current_path = ObjectManager.current_instance.current_path
        ObjectManager.current_instance.object_tracker[ current_path ] = self
        self.inflate_jpath!( opts )
      end

    end
  end
end