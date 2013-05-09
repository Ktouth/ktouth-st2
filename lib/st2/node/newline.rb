module KtouthBrand::ST2
  class NewLine < Node::Inline
    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
    end

    private

    def format_for_source(context)
      context.write ' ' if pre_blank?
      context.write "\n"
    end
  end
end

