require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::NodeValidator" do
  subject { KtouthBrand::ST2::NodeValidator }
  it { should be_instance_of(Class) }
  it { should < KtouthBrand::ReadOnlyCollection }
  
  describe '.new' do
    it { expect { subject.new }.to_not raise_error }
    it { subject.new.instance_variable_get(:@source).should == [] }
  end

  describe '#valid?' do
    subject { KtouthBrand::ST2::NodeValidator.new }
    it { should respond_to(:valid?) }

    it { subject.valid?.should be_nil }
    it { expect { subject.add_message(KtouthBrand::ST2::ErrorMessage.new('error')) }.to change { subject.valid? }.from(nil).to(false) } 
  end

  describe '#add_message' do
    subject { KtouthBrand::ST2::NodeValidator.new }
    it { expect { subject.add_message }.to raise_error(ArgumentError) }
    it { expect { subject.add_message(nil) }.to raise_error(ArgumentError) }
    it { expect { subject.add_message(152321) }.to raise_error(ArgumentError) }
    it { expect { subject.add_message('test') }.to raise_error(ArgumentError) }
    it { expect { subject.add_message(KtouthBrand::ST2::ErrorMessage.new('error')) }.to change { subject.size }.from(0).to(1) } 
  end

  class ExampleNode < KtouthBrand::ST2::Node
    class <<self
      public :new
    end
    def initialize(_id)
      super()
      @id = _id
    end
    attr_reader :id
    def inspect; "<Example: #{id}>" end
    def each_error_message; end
  end
  def create_nodes(num); num.to_i.times.map {|x| ExampleNode.new(x) } end
  def assign_each_node(owner, array, *indexes)
    klass = class <<owner; self end
    klass.send(:define_method, :each_node) do |&block|
      indexes.each {|x| block.call(array[x]) }
    end
  end
  def assign_each_error_message(node, &block)
    klass = class <<node; self end
    klass.send(:define_method, :each_error_message, &block)
  end

  shared_context 'tree nodes' do
    # tree => 0 =>[1, 2 => [3 => [4, 5], 6, 7 => [8 => [9]]], 10 => [11 => [12, 13], 14, 15]]
    before do
      @nodes = create_nodes(16)
      assign_each_node(@nodes[0], @nodes, 1, 2, 10)
      assign_each_node(@nodes[2], @nodes, 3, 6, 7)
      assign_each_node(@nodes[3], @nodes, 4, 5)
      assign_each_node(@nodes[7], @nodes, 8)
      assign_each_node(@nodes[8], @nodes, 9)
      assign_each_node(@nodes[10], @nodes, 11, 14, 15)
      assign_each_node(@nodes[11], @nodes, 12, 13)
    end
  end

  describe '#validate' do
    subject { KtouthBrand::ST2::NodeValidator.new }
    
    it { should be_respond_to(:validate) }
    it { expect { subject.validate }.to raise_error(ArgumentError) }
    it { expect { subject.validate(151) }.to raise_error(ArgumentError) }
    it { expect { subject.validate('test') }.to raise_error(ArgumentError) }
    it { expect { subject.validate(Time.now) }.to raise_error(ArgumentError) }
    it { expect { subject.validate(ExampleNode.new(1)) }.to_not raise_error }

    it { subject.validate(ExampleNode.new(1)).should be_true }
    it { expect { subject.validate(ExampleNode.new(1)) }.to change { subject.valid? }.from(nil).to(true) }

    context 'is scan all tree nodes' do
      include_context 'tree nodes'
      before do
        @result = result = []
        @nodes.each do |n|
          assign_each_error_message(n) { result.push self.inspect }
        end
        @examples = @nodes.map(&:inspect)
      end
      it { expect { subject.validate(@nodes[0]) }.to change { @result }.to(@examples) }
    end

    context 'is found any error messages' do
      include_context 'tree nodes'
      before do
        messages = ['1st error', '2nd error', '3rd error']
        [5, 10, 6].each_with_index do |n, i|
          assign_each_error_message(@nodes[n]) do |&block|
            block.call(make_error_message(messages[i]))
          end
        end
        @result = messages.map {|x| "-:-:#{x}" }
      end
      it { subject.validate(@nodes[0]).should be_false }
      it { expect { subject.validate(@nodes[0]) }.to change { subject.valid? }.from(nil).to(false) }
      it { expect { subject.validate(@nodes[0]) }.to change { subject.size }.from(0).to(@result.size) }
      it { expect { subject.validate(@nodes[0]) }.to change { subject.map {|x| x.to_s }.sort }.from([]).to(@result) }
    end
    
    context 'is raise error when received invalid message' do
      include_context 'tree nodes'
      before do
        assign_each_error_message(@nodes[4]) {|&block| block[make_error_message('test')] }
        assign_each_error_message(@nodes[8]) {|&block| block['invalid text message'] }
      end
      it { expect { subject.validate(@nodes[0]) }.to raise_error(ArgumentError) }
    end
    
    context 'is execute when #valid? is nil(valid pattern)' do
      include_context 'tree nodes'
      before do
        subject.validate(@nodes[0])
        @nodes[0].should_not_receive(:each_error_message)
      end
      it { expect { subject.validate(@nodes[0]) }.to_not change { subject.valid? } }
    end
    
    context 'is execute when #valid? is nil(invalid pattern)' do
      include_context 'tree nodes'
      before do
        subject.add_message(KtouthBrand::ST2::ErrorMessage.new('invalid'))
        @nodes[0].should_not_receive(:each_error_message)
      end
      it { expect { subject.validate(@nodes[0]) }.to_not change { subject.valid? } }
    end
  end
end
