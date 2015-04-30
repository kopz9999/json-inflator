class Array

  include Json::Inflator::Inflatable

  protected

  def inflate_jpath!( opts = {} )
    base_path = Json::Deflator::ObjectManager.current_instance.current_path
    self.map!.with_index do | obj, i |
      Json::Deflator::ObjectManager.current_instance.current_path = 
        "#{ base_path }[#{ i }]"
      obj.deflate_json!(opts)
    end
  end

  def inflate_static_reference!( opts = {} )
    self.map! do | obj |
      obj.deflate_json!(opts)
    end
  end

end