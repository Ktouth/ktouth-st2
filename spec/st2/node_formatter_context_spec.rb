require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
end
