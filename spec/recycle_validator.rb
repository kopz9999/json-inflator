require 'jsonpath'

class RecycleValidator

  attr_accessor :decycled_hash, :recycled_hash, 
    :reference_property, :values_property, :identifier_property,
    :json_root, :context, :mode, :parser

  def initialize( opts )
    self.decycled_hash = opts[:decycled_hash]
    self.recycled_hash = opts[:recycled_hash]
    self.json_root = opts[:json_root] || "$"
    self.reference_property = opts[:reference_property] || 
      Json::Inflator::Parser::Identities::Reference
    self.identifier_property = opts[:identifier_property] || 
      Json::Inflator::Parser::Identities::Identifier
    self.values_property = opts[:values_property] || 
      Json::Inflator::Parser::Identities::Values
    self.context = opts[:context]
    self.parser = opts[:parser]
    self.mode = opts[:mode]
  end

  def validate
    case self.mode
      when :j_path
        jpath_valid_recycle(self.decycled_hash, self.json_root)
      when :static_reference
        static_reference_recycle(self.decycled_hash, self.json_root)
    end
  end

  # Valid with JSON Path
  def static_reference_recycle( object_chunk, json_path )
    case
      when object_chunk.is_a?(Array)
        object_chunk.each_with_index do | el, i |
          static_reference_recycle el, "#{ json_path }[#{ i }]"
        end
      when object_chunk.is_a?(Hash)
        case 
          when object_chunk.has_key?(reference_property)
            # Test Validation

            # Stored Reference
            reference_id = object_chunk[ reference_property ]
            referenced_object = self.parser.object_tracker[ reference_id ]

            # Current Reference
            current_path = JsonPath.new( json_path )
            current_referenced_object = current_path.on( recycled_hash ).first

            # It should be exactly the same object in memory
            self.context.instance_eval do
              expect( referenced_object ).to equal current_referenced_object
            end
          when object_chunk.has_key?(values_property)
            static_reference_recycle object_chunk[ values_property ], json_path
          else
            object_chunk.each do | k, v |
              static_reference_recycle v, "#{ json_path }.#{ k }"
            end
        end
    end
  end

  def jpath_valid_recycle( object_chunk, json_path )
    case
      when object_chunk.is_a?(Array)
        object_chunk.each_with_index do | el, i |
          jpath_valid_recycle el, "#{ json_path }[#{ i }]"
        end
      when object_chunk.is_a?(Hash)
        case 
          when object_chunk.has_key?(reference_property)
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
              jpath_valid_recycle v, "#{ json_path }.#{ k }"
            end
        end
    end
  end

end
