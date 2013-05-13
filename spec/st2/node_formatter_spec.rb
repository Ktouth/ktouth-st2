require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../dummy_node_tree')

describe "KtouthBrand::ST2::NodeFormatter" do
  subject { KtouthBrand::ST2::NodeFormatter }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }

  def abstract_new; KtouthBrand::ST2::NodeFormatter.send(:new) end
  
  describe '.new' do
    it { expect { abstract_new }.to_not raise_error }
    it { abstract_new.instance_variable_get(:@string).should be_instance_of(StringIO) }
  end

  describe '#string' do
    it { abstract_new.should be_respond_to(:string) }
    it { abstract_new.string.should == '' }
    context 'is proxy @string#string' do
      subject { abstract_new }
      def get; subject.instance_variable_get(:@string) end
      it { expect { get.write 'test string' }.to change { subject.string }.from('').to('test string') }
    end
  end

  describe "(#make_context)" do
    before :all do
      @formatter = KtouthBrand::ST2::NodeFormatter.send(:new)
      @parent = KtouthBrand::ST2::NodeFormatterContext.allocate
    end
    subject { @formatter }
    it { should_not be_respond_to(:make_context) }
    it { should be_respond_to(:make_context, true) }

    def create(*args); @formatter.send(:make_context, *args) end

    it { expect { create }.to_not raise_error }
    it { expect { create(nil) }.to_not raise_error }
    it { expect { create(153132) }.to raise_error }
    it { expect { create("nil") }.to raise_error }
    it { expect { create(/test/) }.to raise_error }
    it { expect { create(@parent) }.to_not raise_error }
    
    context 'valid created' do
      subject { create }
      it { subject.instance_variable_get(:@formatter).should == @formatter }
    end
    context 'valid created with parent context' do
      subject { create(@parent) }
      it { subject.instance_variable_get(:@formatter).should == @formatter }
      it { subject.instance_variable_get(:@parent).should == @parent }
    end
    context 'call context initialize' do
      before do
        KtouthBrand::ST2::NodeFormatterContext.should_receive(:new).with(@formatter, nil).once
      end
      it { expect { create }.to_not raise_error }
    end
  end

  describe "(#root_node)" do
    before :all do
      @formatter = KtouthBrand::ST2::NodeFormatter.send(:new)
      @parent = KtouthBrand::ST2::NodeFormatterContext.allocate
    end
    subject { @formatter }
    it { should_not be_respond_to(:root_node) }
    it { should be_respond_to(:root_node, true) }

    def call(*args, &block); @formatter.send(:root_node, *args, &block) end
  
    it { call.should be_nil }
  end
  
  describe "(#set_context_nodes)" do
    before do
      @formatter = KtouthBrand::ST2::NodeFormatter.send(:new)
      @context = @formatter.send(:make_context)
      @pre, @cur, @next = 3.times.map {|x| ExampleNode.new(x) }
    end
    subject { @formatter }

    def set(*args, &block); @formatter.send(:set_context_nodes, *args, &block) end

    it { should_not be_respond_to(:set_context_nodes) }
    it { should be_respond_to(:set_context_nodes, true) }

    it { expect { set }.to raise_error }
    it { expect { set(@context) }.to raise_error }
    it { expect { set(@context, nil) }.to raise_error }
    it { expect { set(@context, @pre, @cur) }.to raise_error }

    it { expect { set(@context, @pre, @cur, @next) }.to_not raise_error }
    it { expect { set(@context, nil, @cur, @next) }.to_not raise_error }
    it { expect { set(@context, @pre, @cur, nil) }.to_not raise_error }
    it { expect { set(@context, nil, @cur, nil) }.to_not raise_error }

    it { expect { set(@context, @pre, nil, @next) }.to raise_error }
    it { expect { set(@context, 156123, @cur, @next) }.to raise_error }
    it { expect { set(@context, @pre, 1253, @next) }.to raise_error }
    it { expect { set(@context, @pre, @cur, 'test') }.to raise_error }
    it { expect { set(@context, :simbole, @cur, :invalid) }.to raise_error }
    it { expect { set(nil, @pre, @cur, @next) }.to raise_error }
    it { expect { set(:unknown, @pre, @cur, @next) }.to raise_error }
    it { expect { set(/notinstance/, @pre, @cur, @next) }.to raise_error }

    def get; [@context.before, @context.current, @context.after] end

    it { expect { set(@context, @pre, @cur, @next) }.to change { get }.from([nil, nil, nil]).to([@pre, @cur, @next]) }
    it { expect { set(@context, nil, @cur, @next) }.to change { get }.from([nil, nil, nil]).to([nil, @cur, @next]) }
    it { expect { set(@context, @pre, @cur, nil) }.to change { get }.from([nil, nil, nil]).to([@pre, @cur, nil]) }
    it { expect { set(@context, nil, @cur, nil) }.to change { get }.from([nil, nil, nil]).to([nil, @cur, nil]) }
  end

  describe "(#call_node)" do
    before do
      @formatter = KtouthBrand::ST2::NodeFormatter.send(:new)
      @context = @formatter.send(:make_context)
      @cur = ExampleNode.new(15)
      @formatter.send(:set_context_nodes, @context, nil, @cur, nil)
    end
    subject { @formatter }

    def call(*args, &block); @formatter.send(:call_node, *args, &block) end

    it { should_not be_respond_to(:call_node) }
    it { should be_respond_to(:call_node, true) }

    it { expect { call }.to raise_error }
    it { expect { call(nil) }.to raise_error }
    it { expect { call(153213) }.to raise_error }
    it { expect { call(/invalid/) }.to raise_error }
    it { expect { call(@context) }.to raise_error }
    it { expect { call(@context, 1536156) }.to raise_error }
    it { expect { call(@context, nil) }.to raise_error }
    it { expect { call(@context, 'test') }.to raise_error }
    it { expect { call(@context, :html) }.to_not raise_error }
    it { expect { call(@context, :html, :text, :inspect) }.to_not raise_error }

    it { expect { call(@context, :test) }.to change { subject.string }.from('').to(@cur.to_s) }
    
    context 'call @context.current.format_for_html' do
      before do
        @cur.should_receive(:format_for_html).with(@context).tap do
          k = class <<@cur; self end
          k.send(:private, :format_for_html)
          
          @cur.should_not be_respond_to(:format_for_html)
        end.once
        @cur.should_not_receive(:format_for_text)
        @cur.should_not_receive(:format_for_inspect)
      end
      it { expect { call(@context, :html) }.to_not raise_error }
    end 
    context 'call @context.current.format_for_text' do
      before do
        @cur.should_receive(:format_for_text).with(@context).tap do
          k = class <<@cur; self end
          k.send(:private, :format_for_text)
          
          @cur.should_not be_respond_to(:format_for_html)
          @cur.should_not be_respond_to(:format_for_text)
          @cur.should_not be_respond_to(:format_for_inspect)
        end.once
      end
      it { expect { call(@context, :html, :text, :inspect) }.to_not raise_error }
    end 
    context 'call @context.current.to_s' do
      before do
        @cur.should_not be_respond_to(:format_for_html)
        @cur.should_not be_respond_to(:format_for_text)
        @cur.should_not be_respond_to(:format_for_inspect)

        str = @cur.to_s
        @cur.should_receive(:to_s).once.and_return(str)
      end
      it { expect { call(@context, :html, :text, :inspect) }.to_not raise_error }
    end 
  end

  describe '#format' do
    before :all do
      @klass = Class.new(KtouthBrand::ST2::NodeFormatter)
      @klass.module_eval do
        def call_node(c); super(c, :dummy) end
      end      
    end
    before do
      @formatter = @klass.send(:new)
    end
    subject { @formatter }

    it { should be_respond_to(:format) }

    it { expect { subject.format }.to raise_error(ArgumentError) }
    it { expect { subject.format(151) }.to raise_error(ArgumentError) }
    it { expect { subject.format('test') }.to raise_error(ArgumentError) }
    it { expect { subject.format(Time.now) }.to raise_error(ArgumentError) }

    context 'result and string' do
      before do
        e = @example = ExampleNode.new(1)
        @formatter.tap do |t|
          c = t.send(:make_context)
          t.should_receive(:make_context).with(nil).once.and_return(c)
          t.should_receive(:set_context_nodes).with(c, nil, e, nil).once do |con, *args|
            con.instance_eval { @before, @current, @after = *args }
          end
        end
      end
      it { expect { subject.format(@example) }.to_not raise_error }
      it { subject.format(@example).should == subject }
      it { expect { subject.format(@example) }.to change { subject.string }.from('').to(@example.to_s) }
    end

    context 'is scan all tree nodes' do
      include_context 'tree nodes'
      before do
        @result = result = []
        @nodes.each do |n|
          assign_format_for(n, :dummy) {|c| result.push self.id }
        end
      end
      it { expect { subject.format(@nodes[0]) }.to change { @result }.to(@tree_current_indexes) }
    end

    context 'is matched context attributes' do
      include_context 'tree nodes'
      def get(sym)
        array = []
        @nodes.each do |n|
          assign_format_for(n, :dummy) {|c| k = c.send(sym); array.push(k.nil? ? nil : k.id) }
        end
        subject.format(@nodes[0])
        array
      end
      def get_parent
        array = []
        @nodes.each do |n|
          assign_format_for(n, :dummy) {|c| k = c.each_ancestor.first; array.push(k.nil? ? nil : k.id) }
        end
        subject.format(@nodes[0])
        array
      end

      it { get(:root).should == @nodes.size.times.map {|x| @nodes[0].id } }
      it { get(:current).should == @tree_current_indexes }
      it { get(:before).should == @tree_before_indexes }
      it { get(:after).should == @tree_after_indexes }
      it { get_parent.should == @tree_parent_indexes }
    end

    context 'is through empty nodes' do
      include_context 'tree nodes'
      def get(sym)
        array = []
        @nodes.each do |n|
          assign_format_for(n, :dummy) {|c| k = c.send(sym); array.push(k.nil? ? nil : k.id) }
        end
        subject.format(@nodes[0])
        array
      end
      before do
        class <<@nodes[0]
          def each_node(&block)
            return self.to_enum(:each_node) unless block
            [].each(&block)
          end
        end
      end
      it { get(:root).should == [0] }
      it { get(:current).should == [0] }
      it { get(:before).should == [nil] }
      it { get(:after).should == [nil] }
    end
  end
end
