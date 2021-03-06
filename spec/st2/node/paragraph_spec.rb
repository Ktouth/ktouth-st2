require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Paragraph" do
  before :all do
    @node_type = KtouthBrand::ST2::Paragraph
    @valid_node = @node_type.new.add_inline(
      KtouthBrand::ST2::Text.new('test'),
      KtouthBrand::ST2::NewLine.new,
      KtouthBrand::ST2::Text.new('valid'),
      KtouthBrand::ST2::Text.new('ok!!', :pre_blank => true)
    )
  end
  include_context "block-node class specset"

  describe '#inlines' do
    before do
      @p = @node_type.new
    end
    subject { @p }
    
    it { should be_respond_to(:inlines) }
    it { subject.inlines.should be_a(KtouthBrand::ReadOnlyCollection) }
    it { subject.inlines.empty?.should be_true }
  end

  describe '#add_inline' do
    before do
      @p = @node_type.new
      @children = [KtouthBrand::ST2::Text.new('test'), KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('valid'), KtouthBrand::ST2::Text.new('ok!!', :pre_blank => true), ]
    end
    subject { @p }

    it { should be_respond_to(:add_inline) }
    it { expect { subject.add_inline }.to raise_error(ArgumentError) }
    it { expect { subject.add_inline(@children.first) }.to_not raise_error }
    it { expect { subject.add_inline(*@children) }.to_not raise_error }
    it { expect { subject.add_inline(nil) }.to raise_error }
    it { expect { subject.add_inline(:abort) }.to raise_error }
    it { expect { subject.add_inline('nil') }.to raise_error }
    it { expect { subject.add_inline(123589) }.to raise_error }
    it { expect { subject.add_inline(@children.last, KtouthBrand::ST2::Paragraph.new) }.to raise_error }
    it { expect { subject.add_inline(*@children[0..2], KtouthBrand::ST2::Node::Inline.send(:new), *@children.last) }.to raise_error }

    it { subject.add_inline(*@children).should == subject }
    it { expect { subject.add_inline(*@children) }.to change { subject.inlines.size }.from(0).to(@children.size) }
    it { expect { subject.add_inline(*@children) }.to change { subject.inlines.to_a }.from([]).to(@children) }

    context 'is not add already exist item' do
      before do
        @p.add_inline(*@children)
      end
      it { expect { subject.add_inline(@children[-1]) }.to_not change { subject.inlines.to_a } }
    end
    context 'is not add duplicated item' do
      before do
        @duplicated = [0, 1, 1, 2, 3, 3, 3].map {|x| @children[x] }
      end
      it { expect { subject.add_inline(*@duplicated) }.to change { subject.inlines.to_a }.to(@children) }
    end
  end  

  describe '#remove_inline' do
    before do
      @children = [KtouthBrand::ST2::Text.new('test'), KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('valid'), KtouthBrand::ST2::Text.new('ok!!', :pre_blank => true), ]
      @p = @node_type.new.add_inline(*@children)
    end
    subject { @p }

    it { should be_respond_to(:remove_inline) }
    it { expect { subject.remove_inline }.to raise_error(ArgumentError) }
    it { expect { subject.remove_inline(@children.first) }.to_not raise_error }
    it { expect { subject.remove_inline(*@children) }.to raise_error }
    it { expect { subject.remove_inline(nil) }.to raise_error }
    it { expect { subject.remove_inline(:abort) }.to raise_error }
    it { expect { subject.remove_inline('nil') }.to raise_error }
    it { expect { subject.remove_inline(123589) }.to raise_error }
    it { expect { subject.remove_inline(KtouthBrand::ST2::Paragraph.new) }.to raise_error }
    it { expect { subject.remove_inline(KtouthBrand::ST2::Node::Inline.send(:new)) }.to raise_error }
    it { expect { subject.remove_inline(KtouthBrand::ST2::Text.new('not found')) }.to_not raise_error }

    it { subject.remove_inline(@children.first).should == subject }
    it { expect { subject.remove_inline(@children[2]) }.to change { subject.inlines.size }.from(@children.size).by(-1) }
    it { expect { subject.remove_inline(@children[1]) }.to change { subject.inlines.to_a }.from(@children).to([@children.first] + @children[2..-1]) }
  end

  describe '#each_node' do
    subject { @valid_node }
    it { should be_respond_to(:each_node) }
    it { subject.each_node.should be_a(Enumerator) }
    it { subject.each_node.to_a.should == subject.inlines.to_a }
    
    context 'is received block' do
      before do
        @result = []
        subject.each_node {|x| @result << x }
      end
      it { @result.should == subject.inlines.to_a }
    end
  end
  
  describe '#each_error_message' do
    def make_and_check(*args)
      node = @node_type.new
      node.add_inline(*args) unless args.empty?
      KtouthBrand::ST2::NodeValidator.new.tap {|t| t.validate(node) }
    end

    it { make_and_check(KtouthBrand::ST2::Text.new('test')).valid?.should be_true }
    it { make_and_check().valid?.should be_false }
    it { make_and_check(KtouthBrand::ST2::Text.new('test'), KtouthBrand::ST2::NewLine.new).valid?.should be_false }
    it { make_and_check(KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('test')).valid?.should be_false }
    it { make_and_check(KtouthBrand::ST2::NewLine.new.tap {|x| x.pre_blank = true }, KtouthBrand::ST2::Text.new('test')).valid?.should be_true }
    it { make_and_check(KtouthBrand::ST2::Text.new('first-line'), KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('test', :pre_blank => true), KtouthBrand::ST2::Text.new('second-line')).valid?.should be_false }
  end

  describe '#format_for_source' do
    def make_and_format(*args)
      node = @node_type.new
      node.add_inline(*args) unless args.empty?
      KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(node) }.string
    end

    it { KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(@valid_node) }.string.should == "test\nvalid ok!!\n" }
    it { make_and_format().should == "" }
    it { make_and_format(KtouthBrand::ST2::Text.new('test')).should == "test\n" }
    it { make_and_format(KtouthBrand::ST2::Text.new('first-line', :pre_blank => true), KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('test'), KtouthBrand::ST2::Text.new('second-line', :pre_blank => true)).should == " first-line\ntest second-line\n" }

    context 'is write blank-space when before-node is Paragraph or other.' do
      def make_and_format(*args)
        node = @node_type.new
        node.add_inline(*args) unless args.empty?
        before = yield

        dummy_group = Class.new(KtouthBrand::ST2::Node).send(:new)
        k = class <<dummy_group
          def format_for_source(context); end
          self
        end
        k.send(:define_method, :each_node) do |&block|
          [before, node].each(&block)
        end

        formatter = KtouthBrand::ST2::SourceFormatter.new
        formatter.format(dummy_group)
        formatter.string
      end
      before :all do
        @valid_texts = "test\nvalid ok!!"
        @paragraph_texts = "first-line\ntest second-line"
        @dummy_node = KtouthBrand::ST2::Node::Block.send(:new).tap do |t|
          class <<t
            def format_for_source(context)
              context.write("---dummy---\n")
            end
          end
        end
      end
      before do
        @array = [KtouthBrand::ST2::Text.new('first-line'), KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('test'), KtouthBrand::ST2::Text.new('second-line', :pre_blank => true)]
      end
      it { @array.first.pre_blank = true; make_and_format(*@array) { @valid_node }.should == "#{@valid_texts}\n #{@paragraph_texts}\n" }
      it { @array.first.pre_blank = false; make_and_format(*@array) { @valid_node }.should == "#{@valid_texts}\n\n#{@paragraph_texts}\n" }
      it { @array.first.pre_blank = true; make_and_format(*@array) { @dummy_node }.should == "---dummy---\n #{@paragraph_texts}\n" }
      it { @array.first.pre_blank = false; make_and_format(*@array) { @dummy_node }.should == "---dummy---\n#{@paragraph_texts}\n" }
    end
  end
end
