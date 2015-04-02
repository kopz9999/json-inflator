module Json
  module Inflator
    
    # Settings object
    class Settings

      attr_accessor :root_symbol

      def initialize( opts )
        self.root_symbol = opts[:root_symbol] || "$"
      end

    end
  end
end
