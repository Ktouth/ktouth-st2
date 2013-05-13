require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "KtouthBrand::ST2::Node" do
  subject { KtouthBrand::ST2::Node }
  it { should be_instance_of(Class) }
  it { should_not be_respond_to(:new) }

  describe '.each_tree' do
    before :all do
      @array = [
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('sample'),
          KtouthBrand::ST2::Text.new('text', :pre_blank => true)
        ),
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('already'),
          KtouthBrand::ST2::NewLine.new,
          KtouthBrand::ST2::Text.new('exist'),
          KtouthBrand::ST2::Text.new('line-text.', :pre_blank => true)
        ),
      ]
      @flatten = @array.map {|x| [x] + x.inlines.to_a }.flatten
    end
    it { should be_respond_to(:each_tree) }

    it { expect { subject.each_tree }.to raise_error }
    it { expect { subject.each_tree(1553) }.to raise_error }
    it { expect { subject.each_tree(nil) }.to raise_error }
    it { expect { subject.each_tree('test') }.to raise_error }
    it { subject.each_tree(@array[0]).should be_a(Enumerator) }
    it { subject.each_tree(@array[0]).to_a.should == @flatten[0..2] }
    it { subject.each_tree(*@array).to_a.should == @flatten }
    it { subject.each_tree(*@array) {|x| :symbol }.should == @array }
  end

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

  describe '#__inline_node?' do
    before do
      @node = KtouthBrand::ST2::Node.send :new
    end
    subject { @node }

    it { should be_respond_to(:__inline_node?) }
    it { subject.__inline_node?.should be_false }
  end

  describe '#__block_node?' do
    before do
      @node = KtouthBrand::ST2::Node.send :new
    end
    subject { @node }

    it { should be_respond_to(:__block_node?) }
    it { subject.__block_node?.should be_false }
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

describe "KtouthBrand::ST2::Node::Inline" do
  subject { KtouthBrand::ST2::Node::Inline }

  it { should be_a(Class) }
  it { should < KtouthBrand::ST2::Node }
  it { should_not be_respond_to(:new) }  

  describe '#__inline_node?' do
    before do
      @inline = KtouthBrand::ST2::Node::Inline.send :new
    end
    subject { @inline }

    it { should be_respond_to(:__inline_node?) }
    it { subject.__inline_node?.should be_true }
  end

  describe '#pre_blank?' do
    before do
      @inline = KtouthBrand::ST2::Node::Inline.send :new
    end
    subject { @inline }

    it { should be_respond_to(:pre_blank?) }
    it { subject.pre_blank?.should be_false }
  end

  describe '#pre_blank=' do
    before do
      @inline = KtouthBrand::ST2::Node::Inline.send :new
    end
    subject { @inline }
    it { should be_respond_to(:pre_blank=) }

    it { expect { subject.pre_blank = true }.to change { subject.pre_blank? }.to(true) }
    it { expect { subject.pre_blank = false }.to_not change { subject.pre_blank? } }
    it { expect { subject.pre_blank = ' ' }.to raise_error(ArgumentError) }
    it { expect { subject.pre_blank = :true }.to raise_error(ArgumentError) }
    it { expect { subject.pre_blank = nil }.to raise_error(ArgumentError) }
  end

  context 'derived from Inline, it can respond to Class.new' do
    before do
      @klass = Class.new(KtouthBrand::ST2::Node::Inline)
    end
    subject { @klass }
    it { should be_respond_to(:new) }
  end
end

describe "KtouthBrand::ST2::Node::Block" do
  subject { KtouthBrand::ST2::Node::Block }

  it { should be_a(Class) }
  it { should < KtouthBrand::ST2::Node }
  it { should_not be_respond_to(:new) }  

  describe '#__block_node?' do
    before do
      @block = KtouthBrand::ST2::Node::Block.send :new
    end
    subject { @block }

    it { should be_respond_to(:__block_node?) }
    it { subject.__block_node?.should be_true }
  end

  context 'derived from Inline, it can respond to Class.new' do
    before do
      @klass = Class.new(KtouthBrand::ST2::Node::Block)
    end
    subject { @klass }
    it { should be_respond_to(:new) }
  end
end
