module Json
  module Inflator
    
    # Settings object
    class Settings

      attr_accessor :root_symbol
      attr_accessor :preserve_arrays

      def initialize( opts = {} )
        self.root_symbol = opts[:root_symbol] || "$"
        preserve_arrays_opt = opts[:preserve_arrays]
        self.preserve_arrays = preserve_arrays_opt.nil? ? true : preserve_arrays_opt
      end

    end
  end
end
