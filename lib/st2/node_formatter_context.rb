require 'forwardable'

module KtouthBrand::ST2
  class NodeFormatterContext
    class <<self
      private :new
    end
    extend Forwardable

    def initialize(formatter, parent = nil)
      raise ArgumentError, 'formatter is not NodeFormatter' unless formatter.is_a?(NodeFormatter)
      raise ArgumentError, 'parent is not NodeFormatterContext' unless parent.nil? || parent.is_a?(NodeFormatterContext)
      @formatter, @parent = formatter, parent
      @current = @before = @after = nil
      @footer = @child_nodes = nil
      @options = @parent ? nil : {}
      @indent_text, @writer = nil, @formatter.instance_variable_get(:@string)
    end
    def_delegator :@formatter, :root_node, :root
    attr_reader :current, :before, :after, :child_nodes, :indent_text

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
      lines = text.to_s.each_line do |line|
        if @writer.__indent_flag
          ary, cur = [], self
          while cur
            ary.push cur.indent_text if cur.indent_text 
            cur = cur.instance_variable_get(:@parent)
          end
          ary.reverse_each {|x| @writer.write(x) }
        end
        @writer.write(line)
        @writer.__indent_flag = line =~ /\n\z/
      end
      self
    end

    def write_escape(text = nil); write(@formatter.send(:escape, text)) end
    
    def indent_text=(val)
      raise ArgumentError, 'val is not string or nil' unless val.nil? || val.is_a?(String)
      @indent_text = val
    end
  end
end