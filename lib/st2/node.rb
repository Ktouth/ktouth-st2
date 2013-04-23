module KtouthBrand::ST2
  class Node
    class <<self
      private :new

      def InlineNode
        Class.new(self).tap do |t|
          class <<t
            public :new
            def inherited(klass)
              class <<klass
                extend Node::Extend
              end
            end
          end
          t.module_eval do
            def __inline_node?; true end
          end
        end
      end

    end
    module Extend
      
    end

    def initialize
      @__source_line__ = @__source_column__ = nil
    end
    attr_accessor :__source_line__, :__source_column__

    def __inline_node?; false end

    private

    def make_error_message(message)
      ErrorMessage.new(message, :line => __source_line__, :column => __source_column__)
    end

    def format_for_source(context)
      raise NotImplementedError, 'class"%s" is not impremented format for "%s"' % [self.class.name, SourceFormatter]
    end
  end
end