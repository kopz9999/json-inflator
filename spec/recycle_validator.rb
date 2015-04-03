class RecycleValidator

  attr_accessor :decycled_hash, :recycled_hash, 
    :reference_property, :json_root, :context

  def initialize( opts )
    self.decycled_hash = opts[:decycled_hash]
    self.recycled_hash = opts[:recycled_hash]
    self.json_root = opts[:json_root] || "$"
    self.reference_property = opts[:reference_property] || 
      Json::Inflator::Parser::Identities::Reference
    self.context = opts[:context]
  end

  def validate
    recycle self.decycled_hash, self.json_root
  end

  def recycle( object_chunk, json_path )
    case
      when object_chunk.is_a?(Array)
        object_chunk.each_with_index do | el, i |
          recycle el, "#{ json_path }[#{ i }]"
        end
      when object_chunk.is_a?(Hash)
        if object_chunk.has_key? reference_property
          # Test Validation

          # Original Reference
          original_path = JsonPath.new( object_chunk[ reference_property ] )
          referenced_object = original_path.on( recycled_hash ).first

          # Current Reference
          current_path = JsonPath.new( json_path )
          current_referenced_object = current_path.on( recycled_hash ).first

          # It should be exactly the same object in memory
          self.context.instance_eval do
            expect( referenced_object ).to equal current_referenced_object
          end
        else
          object_chunk.each do | k, v |
            recycle v, "#{ json_path }.#{ k }"
          end
        end
    end
  end

end
