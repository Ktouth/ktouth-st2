require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::ErrorMessage" do
  before :all do
    @text = 'sample error message!'
  end

  subject { KtouthBrand::ST2::ErrorMessage }
  it { should be_instance_of(Class) }

  describe ".new" do
    context 'argument exceptions' do
      it { expect { subject.new }.to raise_error(ArgumentError) }
      it { expect { subject.new(/invalid/) }.to raise_error(ArgumentError) }
      it { expect { subject.new(15623) }.to raise_error(ArgumentError) }
      it { expect { subject.new('simple', /invalid/) }.to raise_error(ArgumentError) }
    end
    it { subject.new('valid error-message.', :line => 10, :column => 19).should be_a(subject) }
  end

  describe "#message" do
    subject { KtouthBrand::ST2::ErrorMessage.new(@text) }
    it { should be_respond_to(:message) }
    it { subject.message.should == @text }
  end
end
