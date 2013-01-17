require 'forwardable'

module KtouthBrand
  class ReadOnlyCollection
    include Enumerable

    def initialize(array)
      raise ArgumentError, 'Source sequence is not specified' unless array.kind_of?(Enumerable)
      @source = array
    end

    extend Forwardable
    def_delegators :@source, :each, :[], :size, :empty?
    def_delegator :@source, :empty?, :blank?
  end
end