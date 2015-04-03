module Json
  module Inflator
    
    # This object will handle how the object is handled 
    # In this case you can cast or return the object
    class DefaultObjectHandler

      protected

      attr_accessor :parser

      public

      def initialize( parser_val )
        self.parser = parser_val
      end

      # Mutate the array
      def process_object( json_hash, json_path )
        self.parser.object_tracker[ json_path ] = json_hash
        json_hash.each do | k, v |
          json_hash[ k ] = self.parser.inflate!( v, "#{ json_path }.#{ k }" )
        end
      end

    end
  end
end
