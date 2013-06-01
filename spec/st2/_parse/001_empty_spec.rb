require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../parse_specset')

N = KtouthBrand::ST2

describe "KtouthBrand::ST2::PieceReader#each / empty string." do
  before :all do
    @source = ""
    @pieces = [
      # empty pieces
    ]
    @result_document = N::Document.new 
  end
  include_context 'parse example set'
end
