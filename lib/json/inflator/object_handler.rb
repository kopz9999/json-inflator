module Json
  module Inflator
    
    # This abstract class will handle how the object is handled 
    class ObjectHandler

      protected

      attr_accessor :parser

      public

      def initialize( parser_val )
        self.parser = parser_val
      end

      # Mutate the array
      def process_object!( json_hash )
        raise NotImplementedError
      end

    end
  end
end
