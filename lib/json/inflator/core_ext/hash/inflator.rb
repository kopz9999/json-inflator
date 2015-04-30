class Hash

  include Json::Inflator::Inflatable

  protected

  def inflate_jpath!( opts = {} )
    base_path = Json::Deflator::ObjectManager.current_instance.current_path
    self.each do | k, v |
      Json::Deflator::ObjectManager.current_instance.current_path = 
        "#{ base_path }.#{ k }"
      self[k] = v.deflate_json!(opts)
    end
  end

  def inflate_static_reference!( opts = {} )
    self.each do | k, v |
      self[k] = v.deflate_json!(opts)
    end
  end

end