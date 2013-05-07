require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../node_specset')

describe "KtouthBrand::ST2::Text" do
  before :all do
    @node_type = KtouthBrand::ST2::Text
    @valid_node = @node_type.new('valid')
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

  describe '#each_error_message' do
    def make_and_check(text)
      node = @node_type.new(text)
      KtouthBrand::ST2::NodeValidator.new.tap {|t| t.validate(node) }
    end

    it { make_and_check('valid').valid?.should be_true }
    it { make_and_check(nil).valid?.should be_false }
    it { make_and_check('').valid?.should be_false }
    it { make_and_check('  invalid').valid?.should be_false }
    it { make_and_check('invalid\t  ').valid?.should be_false }
    it { make_and_check("unknown\nvalid").valid?.should be_false }
  end

  describe '#format_for_source' do
    before :all do
      @block_chars = ['*) ', '+) ', '>> ', '---', '=== ', '//', '; ',  ]
      @block_chars_result = @block_chars.map {|x| x.sub(/ /, '\\ ') }
    end
    def make_and_format(*args)
      node = @node_type.new(*args)
      KtouthBrand::ST2::SourceFormatter.new.tap {|x| x.format(node) }.string
    end

    it { make_and_format('test').should == 'test' }
    it { make_and_format('valid', :pre_blank => true).should == ' valid' }
    it { make_and_format(nil).should == '' }
    it { make_and_format(nil, :pre_blank => true).should == ' ' }
    it { make_and_format('').should == '' }
    it { make_and_format('', :pre_blank => true).should == ' ' }
    it { make_and_format('   ').should == "\\ \\ \\ " }
    it { make_and_format('     ', :pre_blank => true).should == " \\ \\ \\ \\ \\ " }
    it { make_and_format('{valid}').should == "\\{valid\\}" }
    it { make_and_format('{valid}', :pre_blank => true).should == " \\{valid\\}" }

    context 'block characters in not-first of line is no-eacaped.' do
      def make_and_format(*args)
        node = @node_type.new(*args)
        formatter = KtouthBrand::ST2::SourceFormatter.new
        class <<formatter
          alias orig_make_context make_context
        end
        formatter.should_receive(:make_context).with(any_args()).once.and_return do |*params|
          formatter.send(:orig_make_context, *params).tap do |orig|
            orig.should_receive(:before).with(no_args()).any_number_of_times.and_return( @node_type.new('valid') )
          end
        end
        formatter.format(node)
        formatter.string
      end
      before do
        @texts = @block_chars.map {|x| make_and_format(x) }
        @texts_with_blank = @block_chars.map {|x| make_and_format(x, :pre_blank => true) }
      end
      it { @texts.should == @block_chars_result }
      it { @texts_with_blank.should == @block_chars_result.map {|x| " #{x}" } }
    end

    context 'block characters in first of line is eacaped.' do
      def make_and_format(*args)
        node = @node_type.new(*args)
        formatter = KtouthBrand::ST2::SourceFormatter.new
        class <<formatter
          alias orig_make_context make_context
        end
        formatter.should_receive(:make_context).with(any_args()).once.and_return do |*params|
          formatter.send(:orig_make_context, *params).tap do |orig|
            orig.should_receive(:before).with(no_args()).any_number_of_times.and_return( nil )
          end
        end
        formatter.format(node)
        formatter.string
      end
      before do
        @texts = @block_chars.map {|x| make_and_format(x) }
        @texts_with_blank = @block_chars.map {|x| make_and_format(x, :pre_blank => true) }
      end
      it { @texts.should == @block_chars_result.map {|x| "\\#{x}" } }
      it { @texts_with_blank.should == @block_chars_result.map {|x| " #{x}" } }
    end
  end  
end
