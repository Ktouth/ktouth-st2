module KtouthBrand::ST2
  class Separator < Node::Block
    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
    end

    private

    def format_for_source(context)
      context.write("\n") if context.before
      context.write("---\n")
      context.write("\n") if context.after
    end
  end
end

