module Json
  module Inflator
    
    # This object will handle the process of deflating a JSON
    class Parser

      # modules

      module Identities
        Reference = '$ref'
        Values = '$values'
        Identifier = '$id'
      end

      module Modes
        JPath = :j_path
        StaticReference = :static_reference
      end

      public

      # This attribute contains a handler for casting objects
      attr_accessor :object_handler
      # This attribute contains the class for object_handler
      attr_accessor :object_handler_class

      # This attribute contains the global hash container for
      # JSON objects
      attr_accessor :object_tracker

      attr_accessor :settings

      public

      def initialize( opts = {} )
        self.object_handler_class = opts[:object_handler_class]
        self.settings = Settings.new( opts[:settings] || {} )
        self.object_tracker = Hash.new
      end

      # This methods mutate the provided JSON
      def process!( json_result, mode = nil )
        self.settings.mode = mode unless mode.nil?
        initialize_object_handler
        case self.settings.mode
          when Modes::JPath
            return inflate_jpath!(json_result, self.settings.root_symbol)
          when Modes::StaticReference
            return inflate_static_reference! json_result
        end
      end

      # This methods mutate the provided JSON 
      def inflate_jpath!( json_result, json_path )
        case
          # The object is null
          when json_result.nil?
            return json_result
          # If the object is an array, do the recursive step
          when json_result.is_a?(Array)
            json_result.map!.with_index do | json_obj, i |
              inflate_jpath!(json_obj, "#{ json_path }[#{ i }]" )
            end
            return json_result
          # Your JSON is a hash
          when json_result.is_a?(Hash)
            if json_result.has_key?( Identities::Reference )
              # The object should have been previously stored
              reference = json_result[ Identities::Reference ]
              return self.object_tracker[ reference ] 
            else
              self.object_handler.current_json_path = json_path
              return self.object_handler.process_object!( json_result )
            end
        end
        json_result
      end

      def inflate_static_reference!( json_result )
        case
          # The object is null
          when json_result.nil?
            return json_result
          # If the object is an array, do the recursive step
          when json_result.is_a?(Array)
            json_result.map! do | json_obj |
              inflate_static_reference!(json_obj )
            end
            return json_result
          # Your JSON is a hash
          when json_result.is_a?(Hash)
            case
              when json_result.has_key?( Identities::Reference )
                reference = json_result[ Identities::Reference ]
                return self.object_tracker[ reference ] 
              when json_result.has_key?( Identities::Identifier )
                identifier = json_result[ Identities::Identifier ]
                self.object_handler.current_identifier = identifier
                return self.object_handler.process_object!( json_result )
              else
                self.object_handler.current_identifier = nil
                return self.object_handler.process_object!( json_result )
            end
        end
        json_result        
      end

      private

      def initialize_object_handler
        if self.object_handler_class.nil?
          case self.settings.mode
            when Modes::JPath then self.object_handler_class = JPathHandler
            when Modes::StaticReference
              self.object_handler_class = StaticReferenceHandler
          end
        end
        self.object_handler = object_handler_class.new( self )
      end

    end
  end
end
