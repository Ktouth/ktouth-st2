module KtouthBrand::ST2
  class Document < Node
    class <<self
      public :new
    end

    def initialize
      @sections = KtouthBrand::ReadOnlyCollection.new(@sections_impl = [])
    end
    attr_reader :sections

    def add_section(first_node, *nodes)
      nodes.unshift first_node
      raise ArgumentError, 'nodes contained not Node instance.' unless nodes.all? {|x| x.is_a?(Section) }
      @sections_impl.concat(nodes).uniq!
      self
    end

    def remove_section(node)
      raise ArgumentError, 'node is not Section instance.' unless node.is_a?(Section)
      @sections_impl.delete(node)
      self
    end

    def each_node(&block)
      return self.to_enum(:each_node) unless block
      sections.each(&block)
    end

    def each_error_message
      return self.to_enum(:each_error_message) unless block_given?
      yield make_error_message("sections is empty.") if sections.empty?
    end

    private

    def format_for_source(context)
    end
  end
end

