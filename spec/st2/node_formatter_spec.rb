require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::NodeFormatter" do
  subject { KtouthBrand::ST2::NodeFormatter }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }

  def abstract_new; KtouthBrand::ST2::NodeFormatter.send(:new) end
  
  describe '.new' do
    it { expect { abstract_new }.to_not raise_error }
    it { abstract_new.instance_variable_get(:@string).should be_instance_of(StringIO) }
  end

  describe '#string' do
    it { abstract_new.should be_respond_to(:string) }
    it { abstract_new.string.should == '' }
    context 'is proxy @string#string' do
      subject { abstract_new }
      def get; subject.instance_variable_get(:@string) end
      it { expect { get.write 'test string' }.to change { subject.string }.from('').to('test string') }
    end
  end
end
