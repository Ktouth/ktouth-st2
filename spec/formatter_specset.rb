# spec before(:all) setting parameters
#   @formatter_type : class of derivated from KtouthBrand::ST2::NodeFormatter.
#   @format_for_symbols : symbol array of called formatting method(part of ":format_for_XXX") 
shared_context "formatter class specset" do
  it { @formatter_type.should be_a(Class) }
  it { @formatter_type.should < KtouthBrand::ST2::NodeFormatter }

  it { @formatter_type.should be_respond_to(:new) }

  it { @formatter_for_symbols.should be_a(Array) }
  it { @formatter_for_symbols.should_not be_empty }
  it { @formatter_for_symbols.size.should <= 3 }
  it { @formatter_for_symbols.should be_all {|x| x.is_a?(Symbol) } }

  context 'formatter invoke valid method' do
    before do
      @formatter, @result = @formatter_type.new, nil 
    end
    def get_methodnames(num)
      num = [num, @formatter_for_symbols.size].min
      @formatter_for_symbols[(@formatter_for_symbols.size - num)..-1].map {|x| "format_for_#{x}".to_sym }
    end
    def make_dummy(num, &func)
      dummy, methods = KtouthBrand::ST2::Node.send(:new), get_methodnames(num)
      func = lambda {|x| } unless func

      dummy.tap do |t|
        t.should_receive(methods.first).with(kind_of(KtouthBrand::ST2::NodeFormatterContext)).once { func.call(true) }
        methods[1..-1].each do |sym|
          t.should_not_receive(sym).with(anything()) { func.call(false) }
        end
        klass = class <<t; self end
        klass.send(:private, *methods)
      end
    end
    def invoke_dummy(num)
      if num <= @formatter_for_symbols.size
        make_dummy(num) {|y| @result = y }.tap do |t|
          m = get_methodnames(num).first
          t.should_not be_respond_to(m)
          t.should be_respond_to(m, true)
          @formatter.format(t)
        end
      else
        @result = true
      end
    end
  
    it { expect { invoke_dummy(3) }.to change { @result }.from(nil).to(true) }
    it { expect { invoke_dummy(2) }.to change { @result }.from(nil).to(true) }
    it { expect { invoke_dummy(1) }.to change { @result }.from(nil).to(true) }
  end
end
