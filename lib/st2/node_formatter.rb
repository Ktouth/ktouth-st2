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
    
    def call_node(context, first_method, *methods)
      raise ArgumentError, 'context is not NodeFormatterContext' unless context.is_a?(NodeFormatterContext)
      methods.unshift first_method
      raise ArgumentError, 'methods[%s] is not Symbol' % m.map(&:to_s).join(', ') unless (m = methods.select {|x| !x.is_a?(Symbol) }).empty?

      methods.each do |sym|
        sym = "format_for_#{sym}".to_sym
        return context.current.send(sym, context) if context.current.respond_to?(sym, true)
      end

      context.current.tap {|t| @string.write t.to_s }
    end
  end
end