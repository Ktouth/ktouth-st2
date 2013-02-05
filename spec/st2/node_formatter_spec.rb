require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::NodeFormatter" do
  subject { KtouthBrand::ST2::NodeFormatter }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }
end
