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

    def format(root)
      raise ArgumentError, 'root is not Node' unless root.is_a?(Node)

      @root_node = root
      call_node_array([@root_node])

      self
    end

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

    def call_node_array(enumer, parent_context = nil)
      context, first, second = make_context(parent_context), nil, nil
      count = 0
      enumer.each do |node|
        case count
        when 0; first = node
        when 1; second = node
        when 2
          call_context(context, nil, first, second)
          first, second = call_context(context, first, second, node)
        else           
          first, second = call_context(context, first, second, node)
        end
        count += 1
      end
      if count == 1
        call_context(context, nil, first, nil)
      else
        call_context(context, nil, first, second) if count == 2
        call_context(context, first, second, nil)
      end
    end
    def call_context(context, before, current, after)
      set_context_nodes(context, before, current, after)
      enumer = context.current.respond_to?(:each_node) ? context.current.to_enum(:each_node) : nil
      call_node(context)
      call_node_array(enumer, context) unless enumer.nil?
      [current, after]
    end
  end
end