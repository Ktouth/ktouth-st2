require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
end
