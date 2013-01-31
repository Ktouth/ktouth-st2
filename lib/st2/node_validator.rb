module KtouthBrand::ST2
  class NodeValidator < KtouthBrand::ReadOnlyCollection
    def initialize
      super([])
      @valid_p = nil
    end

    def valid?; @valid_p end

    def add_message(message)
      raise ArgumentError, 'message is not ErrorMessage' unless message.is_a?(ErrorMessage)
      @source.push message
      @valid_p = false
    end
  end
end