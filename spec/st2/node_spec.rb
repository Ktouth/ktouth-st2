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
end
