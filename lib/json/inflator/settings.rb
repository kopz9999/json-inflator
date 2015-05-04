module Json
  module Inflator
    
    # Settings object
    class Settings

      attr_accessor :root_symbol
      attr_accessor :mode
      attr_accessor :preserve_arrays

      alias :preserve_arrays? :preserve_arrays

      def initialize( opts = {} )
        opt_preserve_arrays = opts[:preserve_arrays]
        self.root_symbol = opts[:root_symbol] || "$"
        self.mode = opts[:mode] || Parser::Modes::JPath
        self.preserve_arrays = opt_preserve_arrays.nil? ?
          true : opt_preserve_arrays
      end

    end
  end
end
