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
end