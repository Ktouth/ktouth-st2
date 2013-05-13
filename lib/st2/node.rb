module KtouthBrand::ST2
  class Node
    class <<self
      private :new

      def each_tree(node, *nodes, &block)
        nodes.unshift node
        raise ArgumentError, 'nodes is not all node-instance.' unless nodes.all? {|x| x.is_a?(Node) }
        return self.to_enum(:each_tree, *nodes) unless block
        each_tree_as(nodes, &block)
      end
      def each_tree_as(nodes, &block)
        nodes.each do |node|
          block.call(node)
          each_tree_as(node.to_enum(:each_node), &block) if node.respond_to?(:each_node)
        end
      end
      private :each_tree_as
    end

    def initialize
      @__source_line__ = @__source_column__ = nil
    end
    attr_accessor :__source_line__, :__source_column__

    def __inline_node?; false end
    def __block_node?; false end

    private

    def make_error_message(message)
      ErrorMessage.new(message, :line => __source_line__, :column => __source_column__)
    end

    def format_for_source(context)
      raise NotImplementedError, 'class"%s" is not impremented format for "%s"' % [self.class.name, SourceFormatter]
    end

    def preset_parameters(params)
      params.each {|key, value| send("#{key}=", value) }
    end

    module Extend
      
    end

    class Inline < Node
      class <<self
        def inherited(klass)
          class <<klass
            public :new
            extend Node::Extend
          end
        end
      end

      def initialize
        super
        @pre_blank = false
      end

      def __inline_node?; true end
      def pre_blank?; @pre_blank end
      def pre_blank=(val)
        raise ArgumentError, 'val is not true or false' unless val == !!val
        @pre_blank = val
      end
    end

    class Block < Node
      class <<self
        def inherited(klass)
          class <<klass
            public :new
            extend Node::Extend
          end
        end
      end

      def __block_node?; true end
    end
  end
end