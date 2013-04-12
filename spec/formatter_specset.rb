# spec before(:all) setting parameters
#   @formatter_type : class of derivated from KtouthBrand::ST2::NodeFormatter.
#   @format_for_symbols : symbol array of called formatting method(part of ":format_for_XXX") 
shared_context "formatter class specset" do
  it { @formatter_type.should be_a(Class) }
  it { @formatter_type.should < KtouthBrand::ST2::NodeFormatter }

  it { @formatter_type.should be_respond_to(:new) }
end
