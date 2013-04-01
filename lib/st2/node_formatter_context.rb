require 'forwardable'

module KtouthBrand::ST2
  class NodeFormatterContext
    class <<self
      private :new
      
      private
      
      def make_writer_proxy(parent = nil)
        unless @proxy_class
          @proxy_class = Class.new
          @proxy_class.module_eval do
            def initialize(parent)
              @writer, @parent, @flag = nil, parent, true
            end
            attr_reader :indent_text
            def indent_text=(text)
              raise ArgumentError, 'val is not string or nil' unless text.nil? || text.is_a?(String)
              @indent_text = text
            end
            def write(text = nil)
              text.to_s.each_line do |line|
                if indent?
                  write_with(line, indent_text)
                else
                  write_text(line)
                end 
              end
            end
            def set_writer(io, flag = true)
              @writer, @flag = io, flag
            end
            
            def indent?
              @writer ? @flag : @parent.indent?
            end

            def write_with(text, *indents)
              if @writer
                indents.each {|x| @writer.write(x) if x }
                @writer.write(text)
                @flag = text =~ /\n\z/
              else
                @parent.write_with(text, @parent.indent_text, *indents)
              end
            end
            def write_text(text)
              if @writer
                @writer.write(text)
                @flag = text =~ /\n\z/
              else
                @parent.write_text(text)
              end
            end
          end
        end
        @proxy_class.new(parent)
      end
    end
    extend Forwardable

    def initialize(formatter, parent = nil)
      raise ArgumentError, 'formatter is not NodeFormatter' unless formatter.is_a?(NodeFormatter)
      raise ArgumentError, 'parent is not NodeFormatterContext' unless parent.nil? || parent.is_a?(NodeFormatterContext)
      @formatter, @parent = formatter, parent
      @current = @before = @after = nil
      @footer = @child_nodes = nil
      @options = @parent ? nil : {}
      @writer = (@parent || @formatter).instance_variable_get(:@child_writer)
      @child_writer = self.class.send(:make_writer_proxy, @writer)
    end
    attr_reader :current, :before, :after, :child_nodes
    def_delegator :@formatter, :root_node, :root
    def_delegators :@child_writer, :indent_text, :indent_text=

    def each_ancestor(&block)
      return  to_enum(:each_ancestor) if block.nil?
      cur, r = self, nil
      while cur = cur.instance_variable_get(:@parent)
        r = block.call(cur.current)        
      end
      r
    end

    def set_footer_proc(&proc)
      raise 'no block given' unless proc
      @footer = proc
      nil
    end

    def make_dummy_node(symbol, proc = nil, &block)
      raise ArgumentError, 'symbol is not Symbol' unless symbol.is_a?(Symbol)
      raise ArgumentError, 'proc is not Proc or nil' unless proc.nil? || proc.is_a?(Proc)
      raise ArgumentError, 'block is not given' unless proc || block
      raise ArgumentError, 'conflict proc and block' if proc && block
      
      Node.send(:new).tap do |n|
        sym = "format_for_#{symbol}".to_sym
        k = class <<n; self end
        k.send(:define_method, sym, proc || block)
        k.send(:private, sym)
      end
    end

    def child_nodes=(array)
      raise ArgumentError, 'array is not receive :each' unless array.nil? || array.respond_to?(:each)
      @child_nodes = array || []
    end
    
    def [](key)
      raise ArgumentError, 'key is not string or empty' unless key.kind_of?(String) && (key != '')
      (@parent || @options)[key]
    end
    
    def []=(key, value)
      raise ArgumentError, 'key is not string or empty' unless key.kind_of?(String) && (key != '')
      (@parent || @options)[key] = value
    end

    def write(text = nil)
      @writer.write(text)
      self
    end

    def write_escape(text = nil); write(@formatter.send(:escape, text)) end
  end
end