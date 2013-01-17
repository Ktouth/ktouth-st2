require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "KtouthBrand::ReadOnlyCollection" do
  subject { KtouthBrand::ReadOnlyCollection }
  it { should be_instance_of(Class) }
  it { should < Enumerable }

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

  describe '#each' do
    before :all do
      @object = KtouthBrand::ReadOnlyCollection.new(@source)
    end
    subject { @object }

    it { should respond_to(:each) }
    it { subject.to_a.should == @source }    
  end

  describe '#[]' do
    before :all do
      @object = KtouthBrand::ReadOnlyCollection.new(@source)
    end
    subject { @object }

    it { should respond_to(:[]) }
    it { subject[0 .. -1].should == @source }    
    it { subject[1].should == @source[1] }    
  end
end
