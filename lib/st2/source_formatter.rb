module KtouthBrand::ST2
  class SourceFormatter < NodeFormatter
    private

    def call_node(context); super(context, :source) end
    def escape(text)
      text.gsub(/[\s\{\}\\]/, '\\\\\\&') if text.is_a?(String)
    end
  end
end