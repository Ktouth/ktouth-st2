module KtouthBrand::ST2
  class NodeValidator < KtouthBrand::ReadOnlyCollection
    def initialize
      super([])
    end

    def valid?; nil end
  end
end