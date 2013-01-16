#-- coding: UTF-8 --
module KtouthBrand
  class ReadOnlyCollection
    def initialize(array)
      raise ArgumentError, 'ソースとなる配列が指定されていません' unless array.kind_of?(Enumerable)
    end
  end
end