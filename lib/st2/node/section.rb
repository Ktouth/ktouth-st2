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

    def each_node(&block)
      return self.to_enum(:each_node) unless block
      title_texts.each(&block)
      blocks.each(&block)
    end

    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
      if blocks.empty?
        yield make_error_message("blocks is empty.")
      else
        yield make_error_message("invalid first separator block.") if blocks[0].is_a?(Separator)
        yield make_error_message("invalid last separator block.") if (blocks.size > 1) && blocks[-1].is_a?(Separator)
      end 
    end

    private

    def format_for_source(context)
      if context.before.is_a?(Section)
        context.write("\n------\n")
        context.write("\n") if title_texts.empty?
      end
      unless title_texts.empty?
        context.write '=== '
        sep = context.make_dummy_node(:source) do |c|
          c.write "\n\n"
        end
        context.child_nodes = [title_texts.to_a, sep, blocks.to_a].flatten
      end
    end
  end
end

