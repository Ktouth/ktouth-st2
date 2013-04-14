require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::Node" do
  subject { KtouthBrand::ST2::Node }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }

  describe '#__source_line__' do
    before do
      @node = KtouthBrand::ST2::Node.send :new
    end
    subject { @node }
    
    it { should be_respond_to(:__source_line__) }
    it { should be_respond_to(:__source_line__=) }
    it { subject.__source_line__.should be_nil }
    it { expect { subject.__source_line__ = 9453 }.to change { subject.__source_line__ }.to(9453) }
  end

  describe '#__source_column__' do
    before do
      @node = KtouthBrand::ST2::Node.send :new
    end
    subject { @node }
    
    it { should be_respond_to(:__source_column__) }
    it { should be_respond_to(:__source_column__=) }
    it { subject.__source_column__.should be_nil }
    it { expect { subject.__source_column__ = 122 }.to change { subject.__source_column__ }.to(122) }
  end
  
  describe '(#make_error_message)' do
    def mk(line, column)
      KtouthBrand::ST2::Node.send(:new).tap do |o|
        o.__source_line__ = line
        o.__source_column__ = column
      end
    end
    def call(n, *args, &block); n.send :make_error_message, *args, &block end 
    before do
      @node = KtouthBrand::ST2::Node.send :new
      @nodeA, @nodeB, @nodeC = mk(15, 34), mk(nil, 5), mk(153, nil)
    end
    subject { @node }
    
    it { should_not be_respond_to(:make_error_message) }
    it { should be_respond_to(:make_error_message, true) }
    it { call(@node, 'test').should be_a(KtouthBrand::ST2::ErrorMessage) }
    it { call(@node, 'test').to_s == '-:-:test' }
    it { call(@nodeA, 'test').to_s == '15:34:test' }
    it { call(@nodeB, 'test').to_s == '-:5:test' }
    it { call(@nodeC, 'test').to_s == '153:-:test' }
  end

  describe '(#format_for_source)' do
    before do
      @node = KtouthBrand::ST2::Node.send :new
    end
    subject { @node }
    
    it { should_not be_respond_to(:format_for_source) }
    it { should be_respond_to(:format_for_source, true) }
    it { expect { KtouthBrand::ST2::SourceFormatter.new.format(subject) }.to raise_error(NotImplementedError) }
  end
end
