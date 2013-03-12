require 'forwardable'

module KtouthBrand::ST2
  class NodeFormatterContext
    class <<self
      private :new
    end
    extend Forwardable

    def initialize(formatter, parent = nil)
      raise ArgumentError, 'formatter is not NodeFormatter' unless formatter.is_a?(NodeFormatter)
      raise ArgumentError, 'parent is not NodeFormatterContext' unless parent.nil? || parent.is_a?(NodeFormatterContext)
      @formatter, @parent = formatter, parent
      @current = @before = @after = nil
      @footer = nil
      @child_nodes = nil
    end
    def_delegator :@formatter, :root_node, :root
    attr_reader :current, :before, :after, :child_nodes

    def each_ancestor(&block)
      return  to_enum(:each_ancestor) if block.nil?
      cur, r = self, nil
      while cur = cur.instance_variable_get(:@parent)
        r = block.call(cur.current)        
      end
      r
    end

    def set_footer_proc(&proc)
      raise 'no block given' unless proc
      @footer = proc
      nil
    end

    def make_dummy_node(symbol, proc = nil, &block)
      raise ArgumentError, 'symbol is not Symbol' unless symbol.is_a?(Symbol)
      raise ArgumentError, 'proc is not Proc or nil' unless proc.nil? || proc.is_a?(Proc)
      raise ArgumentError, 'block is not given' unless proc || block
      raise ArgumentError, 'conflict proc and block' if proc && block
      
      Node.send(:new).tap do |n|
        sym = "format_for_#{symbol}".to_sym
        k = class <<n; self end
        k.send(:define_method, sym, proc || block)
        k.send(:private, sym)
      end
    end

    def child_nodes=(array)
      raise ArgumentError, 'array is not receive :each' unless array.nil? || array.respond_to?(:each)
      @child_nodes = array || []
    end
  end
end