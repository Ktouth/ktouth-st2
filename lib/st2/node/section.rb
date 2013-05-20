module KtouthBrand::ST2
  class Section < Node
    class <<self
      public :new
    end

    def initialize
    end

    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
    end

    private

    def format_for_source(context)
    end
  end
end

