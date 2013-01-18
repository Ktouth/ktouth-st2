module KtouthBrand
  module ST2
    class ErrorMessage
      def initialize(message, options = {})
        raise ArgumentError, 'message is invalid text' unless message.kind_of?(String)
        raise ArgumentError, 'invalid option parameter' unless options.kind_of?(Hash)
        line = options.delete(:line)
        raise ArgumentError, 'line options is integer only' unless line.nil? || line.kind_of?(Integer)
        column = options.delete(:column)
        raise ArgumentError, 'column options is integer only' unless column.nil? || column.kind_of?(Integer)

        @message, @line, @column = message, line, column
      end
      attr_reader :message, :line, :column

      def to_s
        [line || '-', column || '-', message].join(':')
      end
    end
  end
end
