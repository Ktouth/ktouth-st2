require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Text" do
  before :all do
    @node_type = KtouthBrand::ST2::Text
    @valid_node = @node_type.new
  end
  include_context "inline-node class specset"
end
