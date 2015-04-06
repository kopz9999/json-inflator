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

      public

      # This attribute contains a handler for casting objects
      attr_accessor :object_handler
      # This attribute contains the class for object_handler
      attr_accessor :object_handler_class

      # This attribute contains the global hash container for
      # JSON objects
      attr_accessor :object_tracker

      # This attribute contains the global hash container for
      # JSON arrays
      attr_accessor :array_tracker

      attr_accessor :settings

      public

      def initialize( opts = {} )
        self.object_handler_class = opts[:object_handler_class] || DefaultObjectHandler
        self.settings = Settings.new( opts[:settings] || {} )
        self.object_tracker = Hash.new
        self.array_tracker = Hash.new
        initialize_object_handler
      end

      # This methods mutate the provided JSON
      def process!( json_result )
        inflate!(json_result, self.settings.root_symbol)
      end

      # This methods mutate the provided JSON 
      def inflate!( json_result, json_path )
        case
          # The object is null
          when json_result.nil?
            return json_result
          # If the object is an array, do the recursive step
          when json_result.is_a?(Array)
            json_result.map!.with_index do | json_obj, i |
              inflate!(json_obj, "#{ json_path }[#{ i }]" )
            end
            return json_result
          # Your JSON is a hash
          when json_result.is_a?(Hash)
            case
              # The object should have been previously stored
              when json_result.has_key?( Identities::Reference ) 
                reference = json_result[ Identities::Reference ]
                return self.object_tracker[ reference ]
              # The object should have been previously stored
              when json_result.has_key?( Identities::Values ) && self.settings.preserve_arrays
                referenced_array = self.array_tracker[ Identities::Identifier ]
                if referenced_array.nil?
                  referenced_array = inflate!(json_result[ Identities::Values ], json_path )
                  self.array_tracker[ Identities::Identifier ] = referenced_array
                end
                return referenced_array
              else
                return self.object_handler.process_object( json_result, json_path )
            end
        end
        json_result
      end

      private

      def initialize_object_handler
        self.object_handler = object_handler_class.new( self )
      end

    end
  end
end
