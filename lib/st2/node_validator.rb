module KtouthBrand::ST2
  class NodeValidator < KtouthBrand::ReadOnlyCollection
    def initialize
      super([])
    end

    def valid?; nil end

    def add_message(message)
      raise ArgumentError, 'message is not ErrorMessage' unless message.is_a?(ErrorMessage)
      @source.push message
    end
  end
end