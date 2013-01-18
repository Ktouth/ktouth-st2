require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::ErrorMessage" do
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
end
