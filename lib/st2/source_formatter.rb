module KtouthBrand::ST2
  class SourceFormatter < NodeFormatter
    private

    def call_node(context); super(context, :source) end
  end
end