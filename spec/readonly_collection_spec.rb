require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "KtouthBrand::ReadOnlyCollection" do
  subject { KtouthBrand::ReadOnlyCollection }
  it { should be_instance_of(Class) }

  before :all do
    @source = [:sample, "test", /is/, 12345]
  end

  describe '.new' do
    it { subject.new(@source).should be_a(subject) }
    it { expect { subject.new }.to raise_error(ArgumentError) }
    it { expect { subject.new(189231) }.to raise_error(ArgumentError) }
    it { expect { subject.new(/test/) }.to raise_error(ArgumentError) }
    it { expect { subject.new('189231') }.to raise_error(ArgumentError) }
    it { expect { subject.new(nil) }.to raise_error(ArgumentError) }
  end
end
