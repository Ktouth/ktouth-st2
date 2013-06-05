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

    def each(&block)
      return to_enum(:each) unless block
      __debug__ "\n************************ scan start!! *************************"
      __debug__ "text: %s" % @scanner.string.inspect
      unless @scanner.eos?
        @lineno, @column, @col_stack = 1, 0, []
        while !@scanner.eos?
          __debug__ "*line: #{@lineno}"
          each_continue_of_line(&block)
          each_block(&block)
          each_inline(&block)
          if scan(/\n/)
            @column = 1 if @column == 0
            block[ token :EOL ]
            @lineno, @column = @lineno + 1, 0
          end
        end
        unless bol?
          @lineno, @column = @lineno + 1, 0
          __debug__ "*line: #{@lineno}"
          @col_stack.each { block[ token :EoBlock ] }
        end
      end
      __debug__ "\n************************ scan end!! ***************************"
    end

    private

    def token(sym, value = nil)
      __debug__ '  [%3d] %s %s' % [@column, sym.inspect, value.nil? ? '' : value.inspect]

      Piece.send(:new, sym, @lineno, @column, value).tap do |t|
        @column += value.size if value.is_a?(String)
      end
    end

    def eol?; @scanner.check(/$/) end
    def bol?; @scanner.bol? end
    def scan(re); @scanner.scan(re) end

    def each_continue_of_line
      if (c = @col_stack.size) > 0
        __debug__ "=== into: continue_of_line"

        @col_stack.each do |re|
          break unless m = scan(re)
#          if m = scan(re)
            @column = 1 if @column == 0
            @column += m.size
            c -= 1
#          else
#            break
#          end
        end
#        c.times do
#          yield token :EoBlock
#          @col_stack.pop
#        end
      end
      @column = 1 if !eol? && (@column == 0) 
    end
    ContinueOfParagraph = /(?=\S)/
    def each_block
      __debug__ "=== into: block"
      while !eol?
#        if scan(/---/)
#          yield token :Separator
#          @column += 3
#          break
#        elsif scan(/(?= )/)
        if scan(/(?= )/)
          yield token :Paragraph
          @col_stack.push(ContinueOfParagraph)
          break
        else
          if @col_stack.last != ContinueOfParagraph
            yield token :Paragraph
            @col_stack.push(ContinueOfParagraph)
          end
          break
        end
      end
    end
    def each_inline
      __debug__ "=== into: inline"
      while !eol?
        if scan(/\\(.)/)
          yield token :Text, @scanner[1]
          @column += 1
        elsif scan(/[ \t]/)
          yield token :Blank
          @column += 1
        elsif w = scan(/[^\s\\\x00-\x08\x0b\x0c\x0e-\x1f]+/)
          yield token :Text, w
        else w = @scanner.getch
          yield token :InvalidChar, w
          __debug__ "invalid char: #{w.inspect}"
        end
      end
    end
    def __debug__(*args)
#      puts(*args)
    end
  end
end