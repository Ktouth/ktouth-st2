require 'stringio'
require 'forwardable'

module KtouthBrand::ST2
  class NodeFormatter
    class <<self
      private :new
    end
    extend Forwardable

    def initialize
      @string, @root_node = StringIO.new, nil
    end
    def string; @string.string.dup end

    private

    def make_context(parent = nil)
      NodeFormatterContext.send(:new, self, parent)
    end
    attr_reader :root_node

    def set_context_nodes(context, before, current, after)
      raise ArgumentError, 'context is not NodeFormatterContext' unless context.is_a?(NodeFormatterContext)
      raise ArgumentError, 'before is not Node' unless before.is_a?(Node) || before.nil?
      raise ArgumentError, 'current is not Node' unless current.is_a?(Node)
      raise ArgumentError, 'after is not Node' unless after.is_a?(Node) || after.nil?
      
      context.instance_eval { @before, @current, @after = before, current, after }
      nil
    end
  end
end