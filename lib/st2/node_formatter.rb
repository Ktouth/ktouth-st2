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
  end
end