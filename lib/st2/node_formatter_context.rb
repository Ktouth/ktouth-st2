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
    end
    def_delegator :@formatter, :root_node, :root
  end
end