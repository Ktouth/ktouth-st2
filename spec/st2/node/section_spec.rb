require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Section" do
  before :all do
    @node_type = KtouthBrand::ST2::Section
    @valid_node = @node_type.new
  end
  include_context "node class specset"

  it { @node_type.should_not < KtouthBrand::ST2::Node::Inline }
  it { @node_type.should_not < KtouthBrand::ST2::Node::Block }
end
