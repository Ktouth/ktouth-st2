module KtouthBrand::ST2
  class Section < Node
    class <<self
      public :new
    end

    def initialize
      @blocks = KtouthBrand::ReadOnlyCollection.new(@blocks_impl = [])
      @title_texts = KtouthBrand::ReadOnlyCollection.new(@title_texts_impl = [])
    end
    attr_reader :blocks, :title_texts

    def add_block(first_node, *nodes)
      nodes.unshift first_node
      raise ArgumentError, 'nodes contained not Node instance.' unless nodes.all? {|x| (x.class < Node::Block) }
      @blocks_impl.concat(nodes).uniq!
      self
    end

    def remove_block(node)
      raise ArgumentError, 'node is not Node::Block instance.' unless node.class < Node::Block
      @blocks_impl.delete(node)
      self
    end

    def add_title_text(first_node, *nodes)
      nodes.unshift first_node
      raise ArgumentError, 'nodes contained not Node instance.' unless nodes.all? {|x| x.is_a?(Text) }
      @title_texts_impl.concat(nodes).uniq!
      self
    end

    def remove_title_text(node)
      raise ArgumentError, 'node is not Text instance.' unless node.is_a?(Text)
      @title_texts_impl.delete(node)
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

