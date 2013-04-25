require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Text" do
  before :all do
    @node_type = KtouthBrand::ST2::Text
    @valid_node = @node_type.new
  end
  include_context "inline-node class specset"

  describe '.new' do
    subject { @node_type }
    it { expect { subject.new }.to_not raise_error }
    it { expect { subject.new(nil) }.to_not raise_error }
    it { expect { subject.new('valid') }.to_not raise_error }
    it { subject.new('valid').text.should == 'valid' }
    it { expect { subject.new(156) }.to raise_error(ArgumentError) }
    it { expect { subject.new(:symbol) }.to raise_error(ArgumentError) }
    it { expect { subject.new(/regexp/) }.to raise_error(ArgumentError) }
    it { expect { subject.new(:text => 'valid') }.to_not raise_error }
    it { subject.new(:text => 'valid').text.should == 'valid' }
    it { expect { subject.new(:pre_blank => true) }.to_not raise_error }
    it { subject.new(:pre_blank => true).pre_blank?.should be_true }
    it { expect { subject.new('test', :pre_blank => true) }.to_not raise_error }
    it { subject.new('test', :pre_blank => true).pre_blank?.should be_true }
    it { expect { subject.new('test', :text => 'valid', :pre_blank => true) }.to_not raise_error }
    it { subject.new('test', :text => 'valid', :pre_blank => true).pre_blank?.should be_true }
    it { subject.new('test', :text => 'valid', :pre_blank => true).text.should == 'test' }
    it { expect { subject.new('test', 12521) }.to raise_error(ArgumentError) }
    it { expect { subject.new('test', :invalid) }.to raise_error(ArgumentError) }
    it { expect { subject.new('test', /regexp/) }.to raise_error(ArgumentError) }
    it { expect { subject.new({:pre_blank => true}, :other => :invalid) }.to raise_error(ArgumentError) }
    it { expect { subject.new(:unknown => true) }.to raise_error(NoMethodError) }
    it { expect { subject.new('test', {:text => 'valid', :pre_blank => true}, :invalid) }.to raise_error(ArgumentError) }
  end

  describe '#text' do
    before do
      @text = @node_type.new
    end
    subject { @text }

    it { should be_respond_to(:text) }
    it { should be_respond_to(:text=) }
    it { subject.text.should be_nil }

    it { expect { subject.text = 'after' }.to change { subject.text }.to('after') }
    it { expect { subject.text = nil }.to_not raise_error(ArgumentError) }
    it { expect { subject.text = false }.to raise_error(ArgumentError) }
    it { expect { subject.text = 15845 }.to raise_error(ArgumentError) }
    it { expect { subject.text = /regexp/ }.to raise_error(ArgumentError) }
    it { expect { subject.text = Class }.to raise_error(ArgumentError) }

    it { expect { subject.text = '  space' }.to_not raise_error(ArgumentError) }
    it { expect { subject.text = 'space ' }.to_not raise_error(ArgumentError) }
    it { expect { subject.text = "space ok" }.to_not raise_error(ArgumentError) }
    it { expect { subject.text = "space\tok\n" }.to_not raise_error(ArgumentError) }
  end
end
