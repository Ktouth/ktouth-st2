# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../parse_specset')

N = KtouthBrand::ST2

describe "KtouthBrand::ST2::PieceReader#each / invalid chars." do
  before :all do
    @source = " test \f \b \a \e invalid."
    @pieces = [
      [:Paragraph, 1, 1, nil],
      [:Blank, 1, 1, nil],
      [:Text, 1, 2, "test"],
      [:Blank, 1, 6, nil],
      [:InvalidChar, 1, 7, "\f"],
      [:Blank, 1, 8, nil],
      [:InvalidChar, 1, 9, "\b"],
      [:Blank, 1, 10, nil],
      [:InvalidChar, 1, 11, "\a"],
      [:Blank, 1, 12, nil],
      [:InvalidChar, 1, 13, "\e"],
      [:Blank, 1, 14, nil],
      [:Text, 1, 15, "invalid."],
      [:EoBlock, 2, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('test', :pre_blank => true),
          N::Text.new('invalid.', :pre_blank => true)
        )
      )
    )
    @errors = [
      [1, 6, "'\\x0c' is invalid charactor."],
      [1, 8, "'\\x08' is invalid charactor."],
      [1, 10, "'\\x07' is invalid charactor."],
      [1, 12, "'\\x1b' is invalid charactor."],
    ]
  end
  include_context 'parse example set'
end

describe "KtouthBrand::ST2::PieceReader#each / multibyte chars." do
  before :all do
    @source = "test 日本語文字列も当然大丈夫。"
    @pieces = [
      [:Paragraph, 1, 1, nil],
      [:Text, 1, 1, "test"],
      [:Blank, 1, 5, nil],
      [:Text, 1, 6, "日本語文字列も当然大丈夫。"],
      [:EoBlock, 2, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('test'),
          N::Text.new('日本語文字列も当然大丈夫。', :pre_blank => true)
        )
      )
    ) 
  end
  include_context 'parse example set'
end
