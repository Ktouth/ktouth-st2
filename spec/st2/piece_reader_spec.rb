require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::Piece" do
  subject { KtouthBrand::ST2::Piece }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }

  def piece(*args); KtouthBrand::ST2::Piece.send(:new, *args) end

  describe "#token" do
    subject { piece(:symbol, 11, 52, "foobar") }
    it { should be_respond_to(:token) }
    it { should_not be_respond_to(:token=) }

    it { subject.token.should == :symbol }    
  end  

  describe "#lineno" do
    subject { piece(:symbol, 11, 52, "foobar") }
    it { should be_respond_to(:lineno) }
    it { should_not be_respond_to(:lineno=) }

    it { subject.lineno.should == 11 }    
  end  

  describe "#column" do
    subject { piece(:symbol, 11, 52, "foobar") }
    it { should be_respond_to(:column) }
    it { should_not be_respond_to(:column=) }

    it { subject.column.should == 52 }    
  end  

  describe "#value" do
    subject { piece(:symbol, 11, 52, "foobar") }
    it { should be_respond_to(:value) }
    it { should_not be_respond_to(:value=) }

    it { subject.value.should == "foobar" }    
  end  
end
