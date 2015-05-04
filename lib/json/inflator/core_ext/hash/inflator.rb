class Hash

  include Json::Inflator::Inflatable

  protected

  def inflate_jpath!( opts = {} )
    base_path = Json::Inflator::ObjectManager.current_instance.current_path
    standard_filtering! opts
    self.each do | k, v |
      if v.is_a?(Hash) || v.is_a?(Array)
        Json::Inflator::ObjectManager.current_instance.current_path = 
          "#{ base_path }.#{ k }"
        self[k] = v.inflate_json!(opts)
      end
    end
  end

  def inflate_static_reference!( opts = {} )
    standard_filtering! opts
    self.each do | k, v |
      if v.is_a?(Hash) || v.is_a?(Array)
        self[k] = v.inflate_json!(opts)
      end
    end
  end

  def standard_filtering!( options )
    if options
      if attrs = options[:only]
        self.slice!(*Array(attrs))
      elsif attrs = options[:except]
        self.except!(*Array(attrs))
      end
    end
  end  

end