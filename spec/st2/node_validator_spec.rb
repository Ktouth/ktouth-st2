require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::NodeValidator" do
  subject { KtouthBrand::ST2::NodeValidator }
  it { should be_instance_of(Class) }
  
  describe '.new' do
    it { expect { subject.new }.to_not raise_error }
  end

  describe '#valid?' do
    subject { KtouthBrand::ST2::NodeValidator.new }
    it { should respond_to(:valid?) }

    it { subject.valid?.should be_nil }
  end
end
