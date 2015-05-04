class Array

  include Json::Inflator::Inflatable

  protected

  def inflate_jpath!( opts = {} )
    base_path = Json::Inflator::ObjectManager.current_instance.current_path
    self.map!.with_index do | obj, i |
      Json::Inflator::ObjectManager.current_instance.current_path = 
        "#{ base_path }[#{ i }]"
      obj.is_a?(Hash) || obj.is_a?(Array) ? obj.inflate_json!(opts) : obj
    end
  end

  def inflate_static_reference!( opts = {} )
    self.map! do | obj |
      obj.is_a?(Hash) || obj.is_a?(Array) ? obj.inflate_json!(opts) : obj
    end
  end

end