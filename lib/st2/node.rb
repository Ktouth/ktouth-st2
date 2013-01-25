module KtouthBrand::ST2
  class Node
    class <<self
      private :new
    end

    def initialize
      @__source_line__ = @__source_column__ = nil
    end
    attr_accessor :__source_line__, :__source_column__

    private

    def make_error_message(message)
      ErrorMessage.new(message, :line => __source_line__, :column => __source_column__)
    end
  end
end