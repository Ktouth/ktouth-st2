require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Section" do
  before :all do
    @node_type = KtouthBrand::ST2::Section
    @valid_node = @node_type.new
    @valid_children = [
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
    ]
    @valid_title_texts = [KtouthBrand::ST2::Text.new('title'), KtouthBrand::ST2::Text.new('valid', :pre_blank => true), KtouthBrand::ST2::Text.new('ok!!', :pre_blank => true), KtouthBrand::ST2::Text.new('prease.', :pre_blank => true), ]
  end
  include_context "node class specset"

  it { @node_type.should_not < KtouthBrand::ST2::Node::Inline }
  it { @node_type.should_not < KtouthBrand::ST2::Node::Block }

  describe '#blocks' do
    before do
      @sec = @node_type.new
    end
    subject { @sec }
    
    it { should be_respond_to(:blocks) }
    it { subject.blocks.should be_a(KtouthBrand::ReadOnlyCollection) }
    it { subject.blocks.empty?.should be_true }
  end

  describe '#add_block' do
    before do
      @sec = @node_type.new
    end
    subject { @sec }

    it { should be_respond_to(:add_block) }
    it { expect { subject.add_block }.to raise_error(ArgumentError) }
    it { expect { subject.add_block(@valid_children.first) }.to_not raise_error }
    it { expect { subject.add_block(*@valid_children) }.to_not raise_error }
    it { expect { subject.add_block(nil) }.to raise_error }
    it { expect { subject.add_block(:abort) }.to raise_error }
    it { expect { subject.add_block('nil') }.to raise_error }
    it { expect { subject.add_block(123589) }.to raise_error }
    it { expect { subject.add_block(@valid_children.last, KtouthBrand::ST2::NewLine.new) }.to raise_error }
    it { expect { subject.add_block(*@valid_children[0..2], KtouthBrand::ST2::Node::Block.send(:new), *@valid_children.last) }.to raise_error }

    it { subject.add_block(*@valid_children).should == subject }
    it { expect { subject.add_block(*@valid_children) }.to change { subject.blocks.size }.from(0).to(@valid_children.size) }
    it { expect { subject.add_block(*@valid_children) }.to change { subject.blocks.to_a }.from([]).to(@valid_children) }

    context 'is not add already exist item' do
      before do
        @sec.add_block(*@valid_children)
      end
      it { expect { subject.add_block(@valid_children[-1]) }.to_not change { subject.blocks.to_a } }
    end
    context 'is not add duplicated item' do
      before do
        @duplicated = [0, 1, 1, 2, 3, 3, 3].map {|x| @valid_children[x] }
      end
      it { expect { subject.add_block(*@duplicated) }.to change { subject.blocks.to_a }.to(@valid_children) }
    end
  end  

  describe '#remove_block' do
    before do
      @sec = @node_type.new.add_block(*@valid_children)
    end
    subject { @sec }

    it { should be_respond_to(:remove_block) }
    it { expect { subject.remove_block }.to raise_error(ArgumentError) }
    it { expect { subject.remove_block(@valid_children.first) }.to_not raise_error }
    it { expect { subject.remove_block(*@valid_children) }.to raise_error }
    it { expect { subject.remove_block(nil) }.to raise_error }
    it { expect { subject.remove_block(:abort) }.to raise_error }
    it { expect { subject.remove_block('nil') }.to raise_error }
    it { expect { subject.remove_block(123589) }.to raise_error }
    it { expect { subject.remove_block(KtouthBrand::ST2::Text.new) }.to raise_error }
    it { expect { subject.remove_block(KtouthBrand::ST2::Node::Block.send(:new)) }.to raise_error }
    it { expect { subject.remove_block(KtouthBrand::ST2::Separator.new) }.to_not raise_error }

    it { subject.remove_block(@valid_children.first).should == subject }
    it { expect { subject.remove_block(@valid_children[2]) }.to change { subject.blocks.size }.from(@valid_children.size).by(-1) }
    it { expect { subject.remove_block(@valid_children[1]) }.to change { subject.blocks.to_a }.from(@valid_children).to([@valid_children.first] + @valid_children[2..-1]) }
  end

  describe '#title_texts' do
    before do
      @sec = @node_type.new
    end
    subject { @sec }
    
    it { should be_respond_to(:title_texts) }
    it { subject.title_texts.should be_a(KtouthBrand::ReadOnlyCollection) }
    it { subject.title_texts.empty?.should be_true }
    it { subject.title_texts.should_not == subject.blocks }
  end

  describe '#add_title_text' do
    before do
      @sec = @node_type.new
    end
    subject { @sec }

    it { should be_respond_to(:add_title_text) }
    it { expect { subject.add_title_text }.to raise_error(ArgumentError) }
    it { expect { subject.add_title_text(@valid_title_texts.first) }.to_not raise_error }
    it { expect { subject.add_title_text(*@valid_title_texts) }.to_not raise_error }
    it { expect { subject.add_title_text(nil) }.to raise_error }
    it { expect { subject.add_title_text(:abort) }.to raise_error }
    it { expect { subject.add_title_text('nil') }.to raise_error }
    it { expect { subject.add_title_text(123589) }.to raise_error }
    it { expect { subject.add_title_text(@valid_title_texts.last, KtouthBrand::ST2::Paragraph.new) }.to raise_error }
    it { expect { subject.add_title_text(@valid_title_texts.last, KtouthBrand::ST2::NewLine.new) }.to raise_error }
    it { expect { subject.add_title_text(*@valid_title_texts[0..2], KtouthBrand::ST2::Node::Inline.send(:new), *@valid_title_texts.last) }.to raise_error }

    it { subject.add_title_text(*@valid_title_texts).should == subject }
    it { expect { subject.add_title_text(*@valid_title_texts) }.to change { subject.title_texts.size }.from(0).to(@valid_title_texts.size) }
    it { expect { subject.add_title_text(*@valid_title_texts) }.to change { subject.title_texts.to_a }.from([]).to(@valid_title_texts) }

    context 'is not add already exist item' do
      before do
        @sec.add_title_text(*@valid_title_texts)
      end
      it { expect { subject.add_title_text(@valid_title_texts[-1]) }.to_not change { subject.title_texts.to_a } }
    end
    context 'is not add duplicated item' do
      before do
        @duplicated = [0, 1, 1, 2, 3, 3, 3].map {|x| @valid_title_texts[x] }
      end
      it { expect { subject.add_title_text(*@duplicated) }.to change { subject.title_texts.to_a }.to(@valid_title_texts) }
    end
  end  

  describe '#remove_title_text' do
    before do
      @sec = @node_type.new.add_title_text(*@valid_title_texts)
    end
    subject { @sec }

    it { should be_respond_to(:remove_title_text) }
    it { expect { subject.remove_title_text }.to raise_error(ArgumentError) }
    it { expect { subject.remove_title_text(@valid_title_texts.first) }.to_not raise_error }
    it { expect { subject.remove_title_text(*@valid_title_texts) }.to raise_error }
    it { expect { subject.remove_title_text(nil) }.to raise_error }
    it { expect { subject.remove_title_text(:abort) }.to raise_error }
    it { expect { subject.remove_title_text('nil') }.to raise_error }
    it { expect { subject.remove_title_text(123589) }.to raise_error }
    it { expect { subject.remove_title_text(KtouthBrand::ST2::Paragraph.new) }.to raise_error }
    it { expect { subject.remove_title_text(KtouthBrand::ST2::NewLine.new) }.to raise_error }
    it { expect { subject.remove_title_text(KtouthBrand::ST2::Node::Inline.send(:new)) }.to raise_error }
    it { expect { subject.remove_title_text(KtouthBrand::ST2::Text.new('not found')) }.to_not raise_error }

    it { subject.remove_title_text(@valid_title_texts.first).should == subject }
    it { expect { subject.remove_title_text(@valid_title_texts[2]) }.to change { subject.title_texts.size }.from(@valid_title_texts.size).by(-1) }
    it { expect { subject.remove_title_text(@valid_title_texts[1]) }.to change { subject.title_texts.to_a }.from(@valid_title_texts).to([@valid_title_texts.first] + @valid_title_texts[2..-1]) }
  end
end
