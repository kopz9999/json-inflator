module Json
  module Inflator
    
    # Settings object
    class Settings

      attr_accessor :root_symbol
      attr_accessor :mode
      attr_accessor :strip_identifiers
      alias :strip_identifiers? :strip_identifiers

      def initialize( opts = {} )
        opt_strip_identifiers = opts[:strip_identifiers]
        self.root_symbol = opts[:root_symbol] || "$"
        self.mode = opts[:mode] || Parser::Modes::JPath
        self.strip_identifiers = opt_strip_identifiers.nil? ? 
          true : opt_strip_identifiers
      end

    end
  end
end
