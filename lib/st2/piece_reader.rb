require 'strscan'

module KtouthBrand::ST2
  class Piece # :nodoc:
    class <<self
      private :new
    end

    def initialize(token, lineno, column, value)
      @token, @lineno, @column, @value = token, lineno, column, value
    end
    attr_reader :token, :lineno, :column, :value
  end

  class PieceReader #:nodoc:
    include Enumerable

    class <<self
      private :new

      def parse(string)
        raise ArgumentError, 'string is not String' unless string.is_a?(String)
        new(StringScanner.new(string))
      end

      def open(filename)
        raise ArgumentError, 'filename is not String' unless filename.is_a?(String)
        str = File.open(filename, 'r') {|io| io.read }
        new(StringScanner.new(str))
      end
      
      def read(stream)
        raise ArgumentError, 'stream is not respond #read' unless stream.respond_to?(:read)
        new(StringScanner.new(stream.read))
      end
    end

    def initialize(scanner)
      @scanner = scanner
    end

    def each
      raise NotImplemented
    end
  end
end