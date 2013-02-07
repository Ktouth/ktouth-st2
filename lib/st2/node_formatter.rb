require 'stringio'
require 'forwardable'

module KtouthBrand::ST2
  class NodeFormatter
    class <<self
      private :new
    end
    extend Forwardable

    def initialize
      @string = StringIO.new
    end
    def string; @string.string.dup end

    private

    def make_context(parent = nil)
      NodeFormatterContext.send(:new, self, parent)
    end
  end
end