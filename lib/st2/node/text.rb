module KtouthBrand::ST2
  class Text < Node::Inline
    def initialize
      super
      @text = nil
    end
    attr_reader :text

    def text=(val)
      raise ArgumentError, 'val is not nil or String' unless val.nil? || val.kind_of?(String)
      @text = val
    end

    def each_error_message; end
    def format_for_source(context)
      
    end
  end
end

