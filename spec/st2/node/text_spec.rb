require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Text" do
  before :all do
    @node_type = KtouthBrand::ST2::Text
    @valid_node = @node_type.new
  end
  include_context "inline-node class specset"

  describe '#text' do
    before do
      @text = KtouthBrand::ST2::Text.new
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
