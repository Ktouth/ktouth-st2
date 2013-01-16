#-- coding: UTF-8 --
require 'forwardable'

module KtouthBrand
  class ReadOnlyCollection
    include Enumerable

    def initialize(array)
      raise ArgumentError, 'ソースとなる配列が指定されていません' unless array.kind_of?(Enumerable)
      @source = array
    end

    extend Forwardable
    def_delegator :@source, :each    
  end
end