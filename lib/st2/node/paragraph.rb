module KtouthBrand::ST2
  class Paragraph < Node::Block
    def initialize
      @inlines = KtouthBrand::ReadOnlyCollection.new(@inlines_impl = [])
    end
    attr_reader :inlines

    def add_inline(first_node, *nodes)
      nodes.unshift first_node
      raise ArgumentError, 'nodes contained not Node instance.' unless nodes.all? {|x| (x.class < Node::Inline) }
      @inlines_impl.concat(nodes).uniq!
      self
    end

    def remove_inline(node)
      raise ArgumentError, 'node is not Node::Inline instance.' unless node.class < Node::Inline
      @inlines_impl.delete(node)
      self
    end

    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
    end

    private

    def format_for_source(context)
    end
  end
end

