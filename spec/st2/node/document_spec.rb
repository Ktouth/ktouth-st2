require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Document" do
  before :all do
    @node_type = KtouthBrand::ST2::Document
    @valid_children = [
      KtouthBrand::ST2::Section.new.add_block(
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('this'), KtouthBrand::ST2::Text.new('section', :pre_blank => true), KtouthBrand::ST2::Text.new('is', :pre_blank => true), KtouthBrand::ST2::Text.new('description.', :pre_blank => true)
        ),
      ),
      KtouthBrand::ST2::Section.new.add_title_text(
        KtouthBrand::ST2::Text.new('title'), KtouthBrand::ST2::Text.new('valid', :pre_blank => true), KtouthBrand::ST2::Text.new('ok!!', :pre_blank => true), KtouthBrand::ST2::Text.new('prease.', :pre_blank => true)
      ).add_block(
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('test'), KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('valid'), KtouthBrand::ST2::Text.new('ok!!', :pre_blank => true)
        ),
        KtouthBrand::ST2::Separator.new,
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('simple-text.', :pre_blank => true)
        ),
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('find'), KtouthBrand::ST2::Text.new('valid!!', :pre_blank => true)
        ),
      ),
      KtouthBrand::ST2::Section.new.add_block(
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('foo'), KtouthBrand::ST2::NewLine.new, KtouthBrand::ST2::Text.new('bar'), KtouthBrand::ST2::Text.new('baz.', :pre_blank => true)
        ),
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('simple-paragraph.', :pre_blank => true)
        ),
      ),
      KtouthBrand::ST2::Section.new.add_title_text( KtouthBrand::ST2::Text.new('footer') ).add_block(
        KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('writer'), KtouthBrand::ST2::Text.new('is', :pre_blank => true), KtouthBrand::ST2::Text.new('K.Ktouth.', :pre_blank => true)
        ),
      ),
    ]
    @valid_node = @node_type.new.add_section(*@valid_children)
    @section_sources = [
      "this section is description.\n",
      "=== title valid ok!! prease.\n\ntest\nvalid ok!!\n\n---\n\n simple-text.\n\nfind valid!!\n",
      "foo\nbar baz.\n simple-paragraph.\n",
      "=== footer\n\nwriter is K.Ktouth.\n",
    ]
    @valid_node_source = "#{@section_sources[0]}\n------\n#{@section_sources[1]}\n------\n\n#{@section_sources[2]}\n------\n#{@section_sources[3]}"
  end
  include_context "node class specset"

  it { @node_type.should_not < KtouthBrand::ST2::Node::Inline }
  it { @node_type.should_not < KtouthBrand::ST2::Node::Block }

  describe '#sections' do
    before do
      @doc = @node_type.new
    end
    subject { @doc }
    
    it { should be_respond_to(:sections) }
    it { subject.sections.should be_a(KtouthBrand::ReadOnlyCollection) }
    it { subject.sections.empty?.should be_true }
  end

  describe '#add_section' do
    before do
      @doc = @node_type.new
    end
    subject { @doc }

    it { should be_respond_to(:add_section) }
    it { expect { subject.add_section }.to raise_error(ArgumentError) }
    it { expect { subject.add_section(@valid_children.first) }.to_not raise_error }
    it { expect { subject.add_section(*@valid_children) }.to_not raise_error }
    it { expect { subject.add_section(nil) }.to raise_error }
    it { expect { subject.add_section(:abort) }.to raise_error }
    it { expect { subject.add_section('nil') }.to raise_error }
    it { expect { subject.add_section(123589) }.to raise_error }
    it { expect { subject.add_section(@valid_children.last, KtouthBrand::ST2::NewLine.new) }.to raise_error }
    it { expect { subject.add_section(@valid_children.last, KtouthBrand::ST2::Separator.new) }.to raise_error }
    it { expect { subject.add_section(*@valid_children[0..2], KtouthBrand::ST2::Node::Block.send(:new), *@valid_children.last) }.to raise_error }

    it { subject.add_section(*@valid_children).should == subject }
    it { expect { subject.add_section(*@valid_children) }.to change { subject.sections.size }.from(0).to(@valid_children.size) }
    it { expect { subject.add_section(*@valid_children) }.to change { subject.sections.to_a }.from([]).to(@valid_children) }

    context 'is not add already exist item' do
      before do
        @doc.add_section(*@valid_children)
      end
      it { expect { subject.add_section(@valid_children[-1]) }.to_not change { subject.sections.to_a } }
    end
    context 'is not add duplicated item' do
      before do
        @duplicated = [0, 1, 1, 2, 3, 3, 3].map {|x| @valid_children[x] }
      end
      it { expect { subject.add_section(*@duplicated) }.to change { subject.sections.to_a }.to(@valid_children) }
    end
  end  

  describe '#remove_section' do
    before do
      @doc = @node_type.new.add_section(*@valid_children)
    end
    subject { @doc }

    it { should be_respond_to(:remove_section) }
    it { expect { subject.remove_section }.to raise_error(ArgumentError) }
    it { expect { subject.remove_section(@valid_children.first) }.to_not raise_error }
    it { expect { subject.remove_section(*@valid_children) }.to raise_error }
    it { expect { subject.remove_section(nil) }.to raise_error }
    it { expect { subject.remove_section(:abort) }.to raise_error }
    it { expect { subject.remove_section('nil') }.to raise_error }
    it { expect { subject.remove_section(123589) }.to raise_error }
    it { expect { subject.remove_section(KtouthBrand::ST2::Text.new) }.to raise_error }
    it { expect { subject.remove_section(KtouthBrand::ST2::Node::Block.send(:new)) }.to raise_error }
    it { expect { subject.remove_section(KtouthBrand::ST2::Separator.new) }.to raise_error }
    it { expect { subject.remove_section(KtouthBrand::ST2::Section.new) }.to_not raise_error }

    it { subject.remove_section(@valid_children.first).should == subject }
    it { expect { subject.remove_section(@valid_children[2]) }.to change { subject.sections.size }.from(@valid_children.size).by(-1) }
    it { expect { subject.remove_section(@valid_children[1]) }.to change { subject.sections.to_a }.from(@valid_children).to([@valid_children.first] + @valid_children[2..-1]) }
  end

  describe '#each_node' do
    subject { @valid_node }
    it { should be_respond_to(:each_node) }
    it { subject.each_node.should be_a(Enumerator) }
    it { subject.each_node.to_a.should == subject.sections.to_a }
    
    context 'is received section' do
      before do
        @result = []
        subject.each_node {|x| @result << x }
      end
      it { @result.should == subject.sections.to_a }
    end
  end
  
  describe '#each_error_message' do
    def make_and_check(*args)
      node = @node_type.new
      node.add_section(*args) unless args.empty?
      KtouthBrand::ST2::NodeValidator.new.tap {|t| t.validate(node) }
    end

    it { make_and_check(@valid_children[0]).valid?.should be_true }
    it { make_and_check(*@valid_children).valid?.should be_true }
    it { make_and_check().valid?.should be_false }
  end

  describe '#format_for_source' do
    def make_and_format(*args)
      node = @node_type.new
      node.add_section(*args) unless args.empty?
      KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(node) }.string
    end

    it { KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(@valid_node) }.string.should == @valid_node_source }
    it { make_and_format().should == "" }
    it { make_and_format(@valid_children[2]).should == @section_sources[2] }
  end
end
