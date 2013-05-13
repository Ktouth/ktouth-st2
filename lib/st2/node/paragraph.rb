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

    def each_node(&block)
      return self.to_enum(:each_node) unless block
      inlines.each(&block)
    end

    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
      if @inlines_impl.empty?
        yield make_error_message("inlines is empty.")
      else 
        yield make_error_message("invalid new-line charactor.") if @inlines_impl.last.is_a?(NewLine) || (@inlines_impl.first.is_a?(NewLine) && !@inlines_impl.first.pre_blank?)
        before = nil
        Node.each_tree(*inlines) do |n|
          yield make_error_message("invalid pre_blank inline node after new-line node.") if before.is_a?(NewLine) && n.pre_blank?
          before = n
        end
      end
    end

    private

    def format_for_source(context)
      context.write "\n" if context.before.is_a?(Paragraph) && !@inlines_impl.empty? && !@inlines_impl.first.pre_blank?
      unless @inlines_impl.empty?
        context.set_footer_proc do |c|
          c.write "\n"
        end
      end
    end
  end
end

