module Json
  module Inflator
    
    # You decide to process the object with JPath
    class JPathHandler < ObjectHandler

      attr_accessor :current_json_path

      # Mutate the array
      def process_object!( json_hash )
        self.parser.object_tracker[ current_json_path ] = json_hash
        json_hash.each do | k, v |
          json_hash[ k ] = self.parser.inflate_jpath!( v, "#{ current_json_path }.#{ k }" )
        end
      end

    end
  end
end