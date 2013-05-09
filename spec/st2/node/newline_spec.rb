require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::NewLine" do
  before :all do
    @node_type = KtouthBrand::ST2::NewLine
    @valid_node = @node_type.new
  end
  include_context "inline-node class specset"

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
    def make_and_check(pre_blank = false)
      node = @node_type.new.tap {|x| x.pre_blank = pre_blank }
      KtouthBrand::ST2::NodeValidator.new.tap {|t| t.validate(node) }
    end

    it { make_and_check().valid?.should be_true }
    it { make_and_check(true).valid?.should be_true }
  end

  describe '#format_for_source' do
    def make_and_format(pre_blank = false)
      node = @node_type.new.tap {|x| x.pre_blank = pre_blank }
      KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(node) }.string
    end

    it { make_and_format().should == "\n" }
    it { make_and_format(true).should == " \n" }
  end  
end
