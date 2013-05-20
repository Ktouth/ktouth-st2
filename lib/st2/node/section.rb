module KtouthBrand::ST2
  class Section < Node
    class <<self
      public :new
    end

    def initialize
      @blocks = KtouthBrand::ReadOnlyCollection.new(@blocks_impl = [])
    end
    attr_reader :blocks

    def add_block(first_node, *nodes)
      nodes.unshift first_node
      raise ArgumentError, 'nodes contained not Node instance.' unless nodes.all? {|x| (x.class < Node::Block) }
      @blocks_impl.concat(nodes).uniq!
      self
    end

    def remove_block(node)
      raise ArgumentError, 'node is not Node::Inline instance.' unless node.class < Node::Block
      @blocks_impl.delete(node)
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

