module Json
  module Inflator
    
    # You decide to process the object with Object References ($id)
    class StaticReferenceHandler < ObjectHandler

      attr_accessor :current_identifier

      # Mutate the array
      def process_object!( json_hash )
        case
          when json_hash.has_key?( Parser::Identities::Values )
            values = json_hash[ Parser::Identities::Values ]
            self.parser.object_tracker[ current_identifier ] = values
            return self.parser.inflate_static_reference!( values )
          else
            self.parser.object_tracker[ current_identifier ] = json_hash
            json_hash.each do | k, v |
              json_hash[ k ] = self.parser.inflate_static_reference!( v )
            end
            return json_hash
        end
      end

    end
  end
end