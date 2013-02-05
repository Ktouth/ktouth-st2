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
    def_delegators :@string, :string
  end
end