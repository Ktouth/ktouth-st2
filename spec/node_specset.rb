# spec before(:all) setting parameters
#   @node_type : class of derivated from KtouthBrand::ST2::Node
#   @valid_node : instance of @node_type. instance validation is true. 
shared_context "node class specset" do
  it { @node_type.should be_a(Class) }
  it { @node_type.should < KtouthBrand::ST2::Node }

  it { @node_type.should be_respond_to(:new) }

  it { @valid_node.should be_a(@node_type) }
  it { @valid_node.should be_respond_to(:each_error_message) }
  it { @valid_node.each_error_message.should be_a(Enumerator) }
  it { @valid_node.should_not be_respond_to(:format_for_source) }
  it { @valid_node.should be_respond_to(:format_for_source, true) }

  context 'validate is true' do
    subject { KtouthBrand::ST2::NodeValidator.new }
    it { subject.validate(@valid_node).should be_true }
  end
  context 'source formatter do not raise error' do
    subject { KtouthBrand::ST2::SourceFormatter.new }
    it { expect { subject.format(@valid_node) }.to_not raise_error }
  end
end

shared_context "inline-node class specset" do
  include_context "node class specset"
  it { @node_type.should < KtouthBrand::ST2::Node::Inline }
end

shared_context "block-node class specset" do
  include_context "node class specset"
  it { @node_type.should < KtouthBrand::ST2::Node::Inline }
end
