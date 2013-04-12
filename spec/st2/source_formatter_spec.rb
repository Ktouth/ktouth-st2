require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../formatter_specset')

describe "KtouthBrand::ST2::SourceFormatter" do
  before :all do
    @formatter_type = KtouthBrand::ST2::SourceFormatter
    @format_for_symbols = []
  end
  include_context 'formatter class specset'
end