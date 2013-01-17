require 'forwardable'

module KtouthBrand
  class ReadOnlyCollection
    include Enumerable

    def initialize(array)
      raise ArgumentError, 'Source sequence is not specified' unless array.kind_of?(Enumerable)
      @source = array
    end

    extend Forwardable
    def_delegator :@source, :each    
  end
end