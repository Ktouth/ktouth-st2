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

describe "KtouthBrand::ST2::PieceReader" do
  subject { KtouthBrand::ST2::PieceReader }
  it { should be_instance_of(Class) }
  it { should < Enumerable }
  it { should_not be_respond_to(:new) }

  def new(*args); KtouthBrand::ST2::PieceReader.send(:new, *args) end
  def get_scanner(reader); reader.instance_variable_get(:@scanner) end

  describe ".parse" do
    it { should be_respond_to(:parse) }
    
    it { expect { subject.parse() }.to raise_error }
    it { expect { subject.parse(12354) }.to raise_error }
    it { expect { subject.parse(nil) }.to raise_error }
    it { expect { subject.parse(/stest/) }.to raise_error }
    it { expect { subject.parse(:symbol) }.to raise_error }
    it { expect { subject.parse(StringIO.new('test')) }.to raise_error }
    it { expect { subject.parse('valid string') }.to_not raise_error }

    it { subject.parse('test string').should be_a(subject) }
    it { get_scanner(subject.parse('test string')).should be_a(StringScanner) }
    it { get_scanner(subject.parse('test string')).string.should == 'test string' }
  end

  describe ".open" do
    it { should be_respond_to(:open) }
    
    it { expect { subject.open() }.to raise_error }
    it { expect { subject.open(12354) }.to raise_error }
    it { expect { subject.open(nil) }.to raise_error }
    it { expect { subject.open(/stest/) }.to raise_error }
    it { expect { subject.open(:symbol) }.to raise_error }
    it { expect { subject.open(StringIO.new('test')) }.to raise_error }

    context 'is open target-file.' do
      before do
        @fname, @string = "foobar.txt", "this is valid string."
        File.should_receive(:open).with(@fname, 'r').once.and_yield(StringIO.new(@string))
      end
      it { expect { subject.open(@fname) }.to_not raise_error }
      it { subject.open(@fname).should be_a(subject) }
      it { get_scanner(subject.open(@fname)).should be_a(StringScanner) }
      it { get_scanner(subject.open(@fname)).string.should == @string }
    end
  end

  describe ".read" do
    it { should be_respond_to(:read) }

    it { expect { subject.read() }.to raise_error }
    it { expect { subject.read(12354) }.to raise_error }
    it { expect { subject.read(nil) }.to raise_error }
    it { expect { subject.read(/stest/) }.to raise_error }
    it { expect { subject.read(:symbol) }.to raise_error }
    it { expect { subject.read('test') }.to raise_error }

    context 'is read target-stream.' do
      before do
        @string = "this is valid string."
        @obj = Object.new.tap do |t|
          t.should_receive(:read).with(no_args()).once.and_return(@string)
        end
      end
      it { expect { subject.read(@obj) }.to_not raise_error }
      it { subject.read(@obj).should be_a(subject) }
      it { get_scanner(subject.read(@obj)).should be_a(StringScanner) }
      it { get_scanner(subject.read(@obj)).string.should == @string }
    end
  end

  describe "#each" do
    before do
      @reader = KtouthBrand::ST2::PieceReader.parse("test string")
    end
    def make_array
      [].tap do |ret|
        reader = KtouthBrand::ST2::PieceReader.parse("test string")
        reader.each {|x| ret.push(x) }
      end
    end
    def compare(a, b)
      [:token, :lineno, :column, :value].all? {|s| a.send(s) == b.send(s) }
    end
    
    subject { @reader }
    it { should be_respond_to(:each) }

    it { expect { subject.each {|x| } }.to_not raise_error }
    it { subject.each.should be_a(Enumerator) }
    it { make_array.zip(subject.each.to_a).should be_all {|a, b| compare(a, b) } }

    context 'result array check' do
      subject { @reader.each.to_a }
      def compare(i, *args)
        [:token, :lineno, :column, :value].map {|s| subject[i].send(s) } == args
      end

      it { should_not be_empty }
      it { should be_all {|x| x.is_a?(KtouthBrand::ST2::Piece) } }
      it { compare(0, :Paragraph, 1, 1, nil).should be_true }
      it { compare(1, :Text, 1, 1, "test").should be_true }
      it { compare(2, :Blank, 1, 5, nil).should be_true }
      it { compare(3, :Text, 1, 6, "string").should be_true }
      it { compare(4, :EoBlock, 2, 0, nil).should be_true }
    end
  end
end
