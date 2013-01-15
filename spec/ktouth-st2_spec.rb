require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "KtouthBrand" do
  subject { KtouthBrand }
  it { should be_instance_of(Module) }

  describe "ST2" do
    subject { KtouthBrand::ST2 }
    it { should be_instance_of(Module) }
  end
end
