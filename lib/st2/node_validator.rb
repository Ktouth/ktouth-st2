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

    def validate(node)
      raise ArgumentError, 'node is Node' unless node.is_a?(Node)

      if @valid_p.nil?
        func = lambda do |cur|
          cur.each_error_message {|x| add_message(x) }
          cur.each_node(&func) if cur.respond_to?(:each_node)
        end
        func.call(node)
        
        @valid_p = true if @valid_p.nil?
      end
      @valid_p
    end
  end
end