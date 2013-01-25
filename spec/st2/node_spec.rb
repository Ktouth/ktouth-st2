require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::Node" do
  subject { KtouthBrand::ST2::Node }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }
end
