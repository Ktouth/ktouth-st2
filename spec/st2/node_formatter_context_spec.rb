require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../dummy_node_tree')

describe "KtouthBrand::ST2::NodeFormatterContext" do
  subject { KtouthBrand::ST2::NodeFormatterContext }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }

  def create(*args); KtouthBrand::ST2::NodeFormatterContext.send(:new, *args) end

  describe "(#initialize)" do
    before :all do
      @formatter = KtouthBrand::ST2::NodeFormatter.send(:new)
      @parent = KtouthBrand::ST2::NodeFormatterContext.allocate
    end
    it { expect { create }.to raise_error }
    it { expect { create(nil) }.to raise_error }
    it { expect { create(153132) }.to raise_error }
    it { expect { create("nil") }.to raise_error }
    it { expect { create(/test/) }.to raise_error }
    it { expect { create(@formatter) }.to_not raise_error }
    
    it { expect { create(@formatter, 336) }.to raise_error }
    it { expect { create(@formatter, 'nil') }.to raise_error }
    it { expect { create(@formatter, /invalid/) }.to raise_error }
    it { expect { create(@formatter, @parent) }.to_not raise_error }
    
    context 'valid created' do
      subject { create(@formatter) }
      it { subject.instance_variable_get(:@formatter).should == @formatter }
    end
    context 'valid created with parent context' do
      subject { create(@formatter, @parent) }
      it { subject.instance_variable_get(:@parent).should == @parent }
    end
  end
  
  shared_context 'context tree' do
    before do
      @formatter = KtouthBrand::ST2::NodeFormatter.send(:new)
      @root = create(@formatter)
      @contexts = [@root, create(@formatter, @root)]
      @contexts.push create(@formatter, @contexts.last)
    end
    subject { @root }
  end
  
  describe "#root" do
    include_context 'context tree'
    before do
      @node = Object.new
      @formatter.should_receive(:root_node).any_number_of_times.and_return(@node)
      class <<@formatter
        private :root_node
      end
    end
    it { @formatter.should_not be_respond_to(:root_node) }
    it { should be_respond_to(:root) }
    it { @contexts.map {|x| x.root }.should == 3.times.map { @node } }
  end
  
  describe "#current" do
    include_context 'context tree'
    it { should be_respond_to(:current) }
    it { subject.current.should be_nil }
  end
  
  describe "#before" do
    include_context 'context tree'
    it { should be_respond_to(:before) }
    it { subject.before.should be_nil }
  end
  
  describe "#after" do
    include_context 'context tree'
    it { should be_respond_to(:after) }
    it { subject.after.should be_nil }
  end

  describe "#each_ancestor" do
    include_context 'context tree'
    it { should be_respond_to(:each_ancestor) }
    it { subject.each_ancestor.should  be_a(Enumerator) }

    context 'is enumerate given block' do
      before do
        @result = []
        @start = 0
        @block = lambda {|c| @result.push(@start += 1); "sym#{@start}".to_sym }
      end
      it { expect { @contexts.last.each_ancestor(&@block) }.to change { @result.dup }.from([]).to([1, 2]) }
      it { @contexts.last.each_ancestor(&@block).should == :sym2 }
    end

    context 'is node array of reverse context tree' do
      before do
        @contexts.each_with_index do |n, i|
          n.should_receive(:current).any_number_of_times.and_return { i }
        end
      end
      it { @contexts[0].each_ancestor.to_a.should == [] }
      it { @contexts[1].each_ancestor.to_a.should == [0] }
      it { @contexts[2].each_ancestor.to_a.should == [1, 0] }
    end
  end

  shared_context 'make node-context' do
    before :all do
      @klass = Class.new(KtouthBrand::ST2::NodeFormatter)
      @klass.module_eval do
        private
        def call_node(c); super(c, :dummy) end     
      end
      @proc = lambda do |c|
        c.should be_a(KtouthBrand::ST2::NodeFormatterContext)
      end
    end
    before do
      @formatter = @klass.send(:new)
      @context = @formatter.send(:make_context) 
    end
  end

  describe "#set_footer_proc" do
    include_context 'make node-context'
    subject { @context }

    def get_footer(context)
      context.instance_variable_get(:@footer)
    end

    it { should be_respond_to(:set_footer_proc) }
    it { subject.instance_variable_get(:@footer).should be_nil }
    it { expect { subject.set_footer_proc }.to raise_error }
    it { expect { subject.set_footer_proc(15, &@proc) }.to raise_error }
    it { expect { subject.set_footer_proc('test', &@proc) }.to raise_error }
    it { expect { subject.set_footer_proc(&@proc) }.to change { get_footer(subject) }.from(nil) }
    it { subject.set_footer_proc(&@proc).should be_nil }
    it { subject.set_footer_proc(&@proc); get_footer(subject).should == @proc }

    context 'all into node' do
      include_context 'tree nodes'
      before do
        @result = []
        @tree_current_indexes_with_footer.sort.should == (@tree_current_indexes + @tree_current_indexes.map {|x| -x }).sort
      end
      def set(&proc)
        @nodes.each do |n|
          n.should_receive(:format_for_dummy) {|c| proc[c] }.once
        end
      end
      def set_footer(context)
        @result.push context.current.id
        context.set_footer_proc do |c|
          @result.push(-context.current.id)
        end
      end
      it { expect { set {|c| @result.push(get_footer(c)); c.set_footer_proc(&@proc) }; @formatter.format(@nodes[0]) }.to change { @result }.to(@nodes.size.times.map {|x| nil }) }
      it { expect { set {|c| set_footer(c) }; @formatter.format(@nodes[0]) }.to change { @result }.to(@tree_current_indexes_with_footer) }
    end
  end

  describe "#make_dummy_node" do
    include_context 'make node-context'
    before do
      @called = _call_ = []
      @proc_dummy = lambda {|c| _call_.push true } 
    end
    subject { @context }
    
    it { should be_respond_to(:make_dummy_node) }
    it { expect { subject.make_dummy_node }.to raise_error }
    it { expect { subject.make_dummy_node(&@proc_dummy) }.to raise_error }
    it { expect { subject.make_dummy_node(154, &@proc_dummy) }.to raise_error }
    it { expect { subject.make_dummy_node('test', &@proc_dummy) }.to raise_error }
    it { expect { subject.make_dummy_node(/test/, &@proc_dummy) }.to raise_error }
    it { expect { subject.make_dummy_node(:dummy, 156358) }.to raise_error }
    it { expect { subject.make_dummy_node(:dummy, '156358') }.to raise_error }
    it { expect { subject.make_dummy_node(:dummy, /invalid/) }.to raise_error }
    it { expect { subject.make_dummy_node(:dummy, @proc_dummy) {|x| } }.to raise_error }

    it { expect { subject.make_dummy_node(:dummy, @proc_dummy) }.to_not raise_error }
    it { expect { subject.make_dummy_node(:dummy, &@proc_dummy) }.to_not raise_error }

    it { subject.make_dummy_node(:dummy, &@proc_dummy).should be_a(KtouthBrand::ST2::Node) }
    it { subject.make_dummy_node(:dummy, &@proc_dummy).should_not be_respond_to(:format_for_dummy) }
    it { subject.make_dummy_node(:dummy, &@proc_dummy).should be_respond_to(:format_for_dummy, true) }
    
    it { expect { subject.make_dummy_node(:dummy, @proc_dummy).send(:format_for_dummy, subject) }.to change { @called.size }.from(0).to(1) }
  end
  
  describe "#child_nodes" do
    include_context 'make node-context'
    include_context 'tree nodes'
    before do
      
    end
    subject { @context }

    def set_current(node); @formatter.send(:set_context_nodes, subject, nil, node, nil) end
    def get_array(num);  
      node = @nodes[num]
      node.respond_to?(:each_node) ? node.to_enum(:each_node).to_a : nil
    end
 

    it { should be_respond_to(:child_nodes) }
    it { should be_respond_to(:child_nodes=) }
    it { subject.child_nodes.should be_nil }
    
    it { expect { set_current(@nodes[22]) }.to_not change { subject.child_nodes.to_a } }
    it { expect { set_current(@nodes[12]) }.to change { subject.child_nodes.to_a }.to(get_array(12)) }
    it { expect { set_current(@nodes[18]) }.to change { subject.child_nodes.to_a }.to(get_array(18)) }
    it { expect { set_current(@nodes[20]) }.to change { subject.child_nodes.to_a }.to(get_array(20)) }
    it { expect { set_current(@nodes[7]) }.to change { subject.child_nodes.to_a }.to(get_array(7)) }

    context 'set value' do
      before do
        set_current(@nodes[20])
        @ary = get_array(20)
      end
      it { expect { @context.child_nodes = nil }.to change { subject.child_nodes.to_a }.from(@ary).to([]) }
      it { expect { @context.child_nodes = [] }.to change { subject.child_nodes.to_a }.from(@ary).to([]) }
      it { expect { @context.child_nodes = get_array(7) }.to change { subject.child_nodes.to_a }.from(@ary).to(get_array(7)) }
      it { expect { @context.child_nodes = 156213 }.to raise_error }
    end
    
    context 'scan for changed nodes' do
      before do
  #  1 -   4 -  8 -  20 -  28
  #                        29
  #                        30
  #        5
  #        6 -  13
        @result = r = []
        @numbers = [1, 4, -100, 8, 20, 28, 29, 30, -200, 5, 6, 13]
        @numbers.select {|x| ![4, -100, -200].include?(x) }.each do |n|
          assign_format_for(@nodes[n], :dummy) {|c| r.push c.current.id }
        end
        new_nodes = @nodes[8]
        assign_format_for(@nodes[4], :dummy) do |c|
          r.push c.current.id
          dmy1 = c.make_dummy_node(:dummy) {|cc| r.push(-100) } 
          dmy2 = c.make_dummy_node(:dummy) {|cc| r.push(-200) }
          c.child_nodes = [dmy1, new_nodes, dmy2] 
        end
      end
      it { expect { @formatter.format(@nodes[1]) }.to_not raise_error }
      it { expect { @formatter.format(@nodes[1]) }.to change { @result }.to(@numbers) }
    end
  end

  describe "#[]" do
    include_context 'make node-context'
    subject { @context }
    
    def get_var(context); context.instance_variable_get(:@options) end
    
    it { should be_respond_to(:[]) }
    it { should be_respond_to(:[]=) }    

    it { get_var(subject).should == {} }

    context 'options access' do
      before do
        get_var(@context).should_receive(:[]).with('number').and_return(190)
      end
      it { subject['number'].should == 190 }
    end
    it { expect { subject[nil] }.to raise_error }
    it { expect { subject[1568213] }.to raise_error }
    it { expect { subject[''] }.to raise_error }
    it { expect { subject[:symbol] }.to raise_error }

    it { expect { subject['test'] = :ok }.to change { get_var(subject)['test'] }.from(nil).to(:ok) }
    it { expect { subject[nil]= 111 }.to raise_error }
    it { expect { subject[1568213]= 111 }.to raise_error }
    it { expect { subject['']= 111 }.to raise_error }
    it { expect { subject[:symbol]= 111 }.to raise_error }

    context 'descendants inherit options access' do
      before do
        @context['test'] = :ok
        @context['this.is'] = 156213
        @child_context = @formatter.send(:make_context, @context)
      end
      subject { @child_context }
      
      it { get_var(subject).should be_nil }
      it { subject['test'].should == :ok }
      it { expect { subject['this.is'] = 'accessed' }.to change { @context['this.is'] }.from(156213).to('accessed') }
      it { expect { subject['new'] = :found }.to change { @context['new'] }.from(nil).to(:found) }
    end
  end

  describe "#write" do
    include_context 'make node-context'
    subject { @context }

    def get_string; @formatter.string end

    it { should be_respond_to(:write) }

    it { expect { subject.write }.to_not change { get_string } }
    it { expect { subject.write('test string') }.to change { get_string }.to('test string') }
    it { expect { subject.write(198231) }.to change { get_string }.to('198231') }
    it { expect { subject.write(/test/) }.to change { get_string }.to(/test/.to_s) }
    it { expect { subject.write(:symbol) }.to change { get_string }.to('symbol') }
    it { expect { subject.write("\n") }.to change { get_string }.to("\n") }
    it { subject.write('string').should == subject }
    it { expect { subject.write('this').write(:is).write(["OK"]) }.to change { get_string }.to('thisis["OK"]') }
  end

  describe "#write_escape" do
    include_context 'make node-context'
    subject { @context }

    def get_string; @formatter.string end

    it { should be_respond_to(:write_escape) }

    it { expect { subject.write_escape }.to_not change { get_string } }
    it { expect { subject.write_escape('test string') }.to change { get_string }.to('test string') }
    it { expect { subject.write_escape(198231) }.to change { get_string }.to('198231') }
    it { expect { subject.write_escape(/test/) }.to change { get_string }.to(/test/.to_s) }
    it { expect { subject.write_escape(:symbol) }.to change { get_string }.to('symbol') }
    it { expect { subject.write_escape("\n") }.to change { get_string }.to("\n") }
    it { subject.write_escape('string').should == subject }

    context 'is call @formatter(#escape)' do
      before do
        @formatter.should_receive(:escape).with("test").and_return("valid result")
        class <<@formatter
          private :escape
        end
        @formatter.should_not be_respond_to(:escape)
      end
      it { expect { subject.write_escape('test') }.to change { get_string }.to('valid result') }
    end
  end
end
