module KtouthBrand::ST2
  class Paragraph < Node::Block
    def initialize
      @inlines = KtouthBrand::ReadOnlyCollection.new(@inlines_impl = [])
    end
    attr_reader :inlines

    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
    end

    private

    def format_for_source(context)
    end
  end
end

