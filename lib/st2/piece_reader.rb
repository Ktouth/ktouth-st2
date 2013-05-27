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
      return to_enum(:each) unless block_given?
      @lineno, @column = 0, 0

      # dummy code
      @lineno, @column = 1, 1; yield token(:BoParagraph)
      @lineno, @column = 1, 1; yield token(:Text, "test")
      @lineno, @column = 1, 5; yield token(:Blank)
      @lineno, @column = 1, 6; yield token(:Text, "string")
      @lineno, @column = 2, 0; yield token(:EoBlock)
    end

    private

    def token(sym, value = nil)
      Piece.send(:new, sym, @lineno, @column, value)
    end
  end
end