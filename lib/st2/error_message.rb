module KtouthBrand
  module ST2
    class ErrorMessage
      def initialize(message, options = {})
        raise ArgumentError, 'message is invalid text' unless message.kind_of?(String)
        raise ArgumentError, 'invalid option parameter' unless options.kind_of?(Hash)
        
        @message = message
      end
      attr_reader :message
    end
  end
end