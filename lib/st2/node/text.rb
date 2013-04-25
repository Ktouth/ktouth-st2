module KtouthBrand::ST2
  class Text < Node::Inline
    def initialize(text = nil, params = nil)
      super()
      if text.is_a?(Hash)
        raise ArgumentError, 'double parameter setted' if params
        preset_parameters(text)
      elsif params.is_a?(Hash)
        preset_parameters(params.merge(:text => text))
      elsif params.nil?
        self.text = text
      else
        raise ArgumentError, 'params is not Hash'
      end
    end
    attr_reader :text

    def text=(val)
      raise ArgumentError, 'val is not nil or String' unless val.nil? || val.kind_of?(String)
      @text = val
    end

    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
      yield make_error_message('text is null or empty string.') if text.nil? || text.empty?
      yield make_error_message('text is contain any blanks.') if text =~ /\s/
    end
    def format_for_source(context)
      
    end
  end
end

