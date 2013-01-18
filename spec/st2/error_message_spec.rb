require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::ErrorMessage" do
  before :all do
    @text = 'sample error message!'
    @lineno = 152
    @column = 11
  end

  subject { KtouthBrand::ST2::ErrorMessage }
  it { should be_instance_of(Class) }

  describe ".new" do
    context 'argument exceptions' do
      it { expect { subject.new }.to raise_error(ArgumentError) }
      it { expect { subject.new(/invalid/) }.to raise_error(ArgumentError) }
      it { expect { subject.new(15623) }.to raise_error(ArgumentError) }
      it { expect { subject.new('simple', /invalid/) }.to raise_error(ArgumentError) }

      it { expect { subject.new(@text, :line => /invalid/) }.to raise_error(ArgumentError) }
      it { expect { subject.new(@text, :line => 'this option is integer only') }.to raise_error(ArgumentError) }

      it { expect { subject.new(@text, :column => /invalid/) }.to raise_error(ArgumentError) }
      it { expect { subject.new(@text, :column => 'this option is integer only') }.to raise_error(ArgumentError) }
    end
    it { subject.new('valid error-message.', :line => 10, :column => 19).should be_a(subject) }
  end

  describe "#message" do
    subject { KtouthBrand::ST2::ErrorMessage.new(@text) }
    it { should be_respond_to(:message) }
    it { subject.message.should == @text }
  end

  describe "#line" do
    subject { KtouthBrand::ST2::ErrorMessage.new(@text) }
    it { should be_respond_to(:line) }
    it { subject.line.should be_nil }
    
    context 'set :lineno option' do
      subject { KtouthBrand::ST2::ErrorMessage.new(@text, :line => @lineno) }
      it { subject.line.should == @lineno }
    end
  end

  describe "#column" do
    subject { KtouthBrand::ST2::ErrorMessage.new(@text) }
    it { should be_respond_to(:column) }
    it { subject.column.should be_nil }
    
    context 'set :columnno option' do
      subject { KtouthBrand::ST2::ErrorMessage.new(@text, :column => @column) }
      it { subject.column.should == @column }
    end
  end
  
  describe "#to_s" do
    context 'no options message' do
      subject { KtouthBrand::ST2::ErrorMessage.new(@text) }
      it { subject.to_s.should == ['-', '-', @text].join(':') }
    end 
    context 'no :column option message' do
      subject { KtouthBrand::ST2::ErrorMessage.new(@text, :line => @lineno) }
      it { subject.to_s.should == [@lineno, '-', @text].join(':') }
    end 
    context 'no ;line option message' do
      subject { KtouthBrand::ST2::ErrorMessage.new(@text, :column => @column) }
      it { subject.to_s.should == ['-', @column, @text].join(':') }
    end 
    context 'full options message' do
      subject { KtouthBrand::ST2::ErrorMessage.new(@text, :line => @lineno, :column => @column) }
      it { subject.to_s.should == [@lineno, @column, @text].join(':') }
    end 
  end
end
