require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Separator" do
  before :all do
    @node_type = KtouthBrand::ST2::Separator
    @valid_node = @node_type.new
  end
  include_context "block-node class specset"

  describe '.new' do
    subject { @node_type }
    it { expect { subject.new }.to_not raise_error }
    it { expect { subject.new(nil) }.to raise_error }
    it { expect { subject.new('valid') }.to raise_error }
    it { expect { subject.new(156) }.to raise_error(ArgumentError) }
    it { expect { subject.new(:symbol) }.to raise_error(ArgumentError) }
    it { expect { subject.new(/regexp/) }.to raise_error(ArgumentError) }
  end

  describe '#each_error_message' do
    def make_and_check()
      node = @node_type.new
      KtouthBrand::ST2::NodeValidator.new.tap {|t| t.validate(node) }
    end

    it { make_and_check().valid?.should be_true }
  end

  describe '#format_for_source' do
    def make_and_format()
      node = @node_type.new
      KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(node) }.string
    end

    it { make_and_format().should == "---\n" }

    context 'is write blank-line when before-node/after-node is Paragraph or other.' do
      before :all do
        @dummy_node = KtouthBrand::ST2::Node::Block.send(:new).tap do |t|
          class <<t
            def format_for_source(context)
              context.write("***dummy***\n")
            end
          end
        end
        @dummy_node_text = "***dummy***\n"
        @dummy_paragraph = KtouthBrand::ST2::Paragraph.new.add_inline(
          KtouthBrand::ST2::Text.new('first-line'),
          KtouthBrand::ST2::NewLine.new,
          KtouthBrand::ST2::Text.new('test'),
          KtouthBrand::ST2::Text.new('second-line', :pre_blank => true)
        )
        @dummy_paragraph_text = "first-line\ntest second-line\n"
      end
      def make_and_format(*nodes)
        dummy_group = Class.new(KtouthBrand::ST2::Node).send(:new)
        k = class <<dummy_group
          def format_for_source(context); end
          self
        end
        k.send(:define_method, :each_node) do |&block|
          nodes.each(&block)
        end

        formatter = KtouthBrand::ST2::SourceFormatter.new
        formatter.format(dummy_group)
        formatter.string
      end

      it { make_and_format(@dummy_node, @valid_node).should == "#{@dummy_node_text}\n---\n" }
      it { make_and_format(@valid_node, @dummy_paragraph, @dummy_node).should == "---\n\n#{@dummy_paragraph_text}#{@dummy_node_text}" }
      it { make_and_format(@dummy_paragraph, @valid_node, @dummy_node).should == "#{@dummy_paragraph_text}\n---\n\n#{@dummy_node_text}" }
    end
  end  
end
