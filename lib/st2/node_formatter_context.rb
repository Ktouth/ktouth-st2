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
      @current = nil
    end
    def_delegator :@formatter, :root_node, :root
    attr_reader :current

    def each_ancestor(&block)
      return  to_enum(:each_ancestor) if block.nil?
      cur, r = self, nil
      while cur = cur.instance_variable_get(:@parent)
        r = block.call(cur.current)        
      end
      r
    end
  end
end