module Json
  module Inflator
    module Inflatable

      # @opts =
      #   - :except = array of keys to exclude from object attributes
      #   - :only = array of keys to include from object attributes
      #   - :settings = 
      #     - instance of class Json::Deflator::Settings
      def inflate_json!(opts = {})
        if ObjectManager.current_instance.nil?
          # this means that there's no current iteration
          result = Thread.new do
            ObjectManager.current_instance = 
              ObjectManager.new( settings: opts.delete(:settings) )
            self.evaluate! opts
          end
          result.join
          result.value
        else
          # Keep iterating
          self.evaluate! opts
        end
      end

      protected

      def evaluate!( opts = {})
        case ObjectManager.current_instance.settings.mode
          when Json::Deflator::Modes::JPath
            return evaluate_inflate_jpath!( opts )
          when Json::Deflator::Modes::StaticReference
            return evaluate_inflate_static_reference!( opts )
        end
      end

      def inflate_jpath!( opts = {} )
        raise NotImplementedError
      end

      def inflate_static_reference!( opts = {} )
        raise NotImplementedError
      end

      private

      def evaluate_inflate_static_reference!( opts = {} )
        if self.is_a?(Array)
          return ObjectManager.current_instance.settings.preserve_arrays? ? 
            check_reference_for_static_reference!(opts) : 
              self.deflate_static_reference!( opts )
        else
          return check_reference_for_static_reference!(opts)
        end
      end

      # Store this one and solve circular references
      def check_reference_for_static_reference!( opts = {} )
        assert_recursion opts do | reference_id |
          identity = ObjectManager.current_instance.next_identity
          ObjectManager.current_instance.reference_tracker[ reference_id ] = identity
          result = self.deflate_static_reference!( opts )
          if self.is_a?(Array)
            { Json::Deflator::Identities::Values => result, 
              Json::Deflator::Identities::Identifier => identity }
          else
            # Opposite case is always a hash
            result[ Json::Deflator::Identities::Identifier ] = identity
            result
          end
        end    
      end

      def evaluate_inflate_jpath!( opts = {} )
        if self.is_a?(Array)
          return ObjectManager.current_instance.settings.preserve_arrays? ? 
            store_reference_for_jpath!(opts) : self.inflate_jpath!( opts )
        else
          # Contrary case is always a Hash
          return store_reference_for_jpath!(opts)
        end
      end

      # Store this one and solve circular references
      def store_reference_for_jpath!(opts)
        current_path = ObjectManager.current_instance.current_path
        ObjectManager.current_instance.object_tracker[ current_path ] = self
        self.inflate_jpath!( opts )
      end

    end
  end
end