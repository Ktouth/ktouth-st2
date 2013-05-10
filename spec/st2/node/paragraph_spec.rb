require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Paragraph" do
  before :all do
    @node_type = KtouthBrand::ST2::Paragraph
    @valid_node = @node_type.new
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
  
  describe '#each_error_message' do
    def make_and_check(pre_blank = false)
      node = @node_type.new.tap {|x| x.pre_blank = pre_blank }
      KtouthBrand::ST2::NodeValidator.new.tap {|t| t.validate(node) }
    end

    it #{ make_and_check().valid?.should be_true }
    it #{ make_and_check(true).valid?.should be_true }
  end

  describe '#format_for_source' do
    def make_and_format(pre_blank = false)
      node = @node_type.new.tap {|x| x.pre_blank = pre_blank }
      KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(node) }.string
    end

    it #{ make_and_format().should == "\n" }
    it #{ make_and_format(true).should == " \n" }
  end  
end
