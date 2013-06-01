require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../parse_specset')

N = KtouthBrand::ST2

describe "KtouthBrand::ST2::PieceReader#each / simple paragpraph. / one token." do
  before :all do
    @source = "one-token."
    @pieces = [
      [:Paragraph, 1, 1, nil],
      [:Text, 1, 1, "one-token."],
      [:EoBlock, 2, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('one-token.')
        )
      )
    ) 
  end
  include_context 'parse example set'
end

describe "KtouthBrand::ST2::PieceReader#each / simple paragpraph. / one token and pre-blanklines." do
  before :all do
    @source = "\n\n\none-token."
    @pieces = [
      [:EOL, 1, 1, nil],
      [:EOL, 2, 1, nil],
      [:EOL, 3, 1, nil],
      [:Paragraph, 4, 1, nil],
      [:Text, 4, 1, "one-token."],
      [:EoBlock, 5, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('one-token.')
        )
      )
    ) 
  end
  include_context 'parse example set'
end

describe "KtouthBrand::ST2::PieceReader#each / simple paragpraph. / one token and pre-blank." do
  before :all do
    @source = " one-token."
    @pieces = [
      [:Paragraph, 1, 1, nil],
      [:Blank, 1, 1, nil],
      [:Text, 1, 2, "one-token."],
      [:EoBlock, 2, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('one-token.', :pre_blank => true)
        )
      )
    ) 
  end
  include_context 'parse example set'
end

describe "KtouthBrand::ST2::PieceReader#each / simple paragpraph. / multi tokens and pre-blank." do
  before :all do
    @source = " one-token and\ttwo token."
    @pieces = [
      [:Paragraph, 1, 1, nil],
      [:Blank, 1, 1, nil],
      [:Text, 1, 2, "one-token"],
      [:Blank, 1, 11, nil],
      [:Text, 1, 12, "and"],
      [:Blank, 1, 15, nil],
      [:Text, 1, 16, "two"],
      [:Blank, 1, 19, nil],
      [:Text, 1, 20, "token."],
      [:EoBlock, 2, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('one-token', :pre_blank => true),
          N::Text.new('and', :pre_blank => true),
          N::Text.new('two', :pre_blank => true),
          N::Text.new('token.', :pre_blank => true)
        )
      )
    ) 
  end
  include_context 'parse example set'
end

describe "KtouthBrand::ST2::PieceReader#each / simple paragpraph. / multiline tokens" do
  before :all do
    @source = "multiline tokens\nthis is last-text."
    @pieces = [
      [:Paragraph, 1, 1, nil],
      [:Text, 1, 1, "multiline"],
      [:Blank, 1, 10, nil],
      [:Text, 1, 11, "tokens"],
      [:EOL, 1, 17, nil],
      [:Text, 2, 1, "this"],
      [:Blank, 2, 5, nil],
      [:Text, 2, 6, "is"],
      [:Blank, 2, 8, nil],
      [:Text, 2, 9, "last-text."],
      [:EoBlock, 3, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('multiline'),
          N::Text.new('tokens', :pre_blank => true),
          N::NewLine.new,
          N::Text.new('this'),
          N::Text.new('is', :pre_blank => true),
          N::Text.new('last-text.', :pre_blank => true)
        )
      )
    ) 
  end
  include_context 'parse example set'
end

describe "KtouthBrand::ST2::PieceReader#each / simple paragpraph. / multiline tokens and included escaped-character" do
  before :all do
    @source = "multiline ; tokens\n\\{this is last-text\\}."
    @pieces = [
      [:Paragraph, 1, 1, nil],
      [:Text, 1, 1, "multiline"],
      [:Blank, 1, 10, nil],
      [:Text, 1, 11, ";"],
      [:Blank, 1, 12, nil],
      [:Text, 1, 13, "tokens"],
      [:EOL, 1, 19, nil],
      [:Text, 2, 1, "{"],
      [:Text, 2, 3, "this"],
      [:Blank, 2, 7, nil],
      [:Text, 2, 8, "is"],
      [:Blank, 2, 10, nil],
      [:Text, 2, 11, "last-text"],
      [:Text, 2, 20, "}"],
      [:Text, 2, 22, "."],
      [:EoBlock, 3, 0, nil],
    ]
    @result_document = N::Document.new.add_section(
      N::Section.new.add_block(
        N::Paragraph.new.add_inline(
          N::Text.new('multiline'),
          N::Text.new(';', :pre_blank => true),
          N::Text.new('tokens', :pre_blank => true),
          N::NewLine.new,
          N::Text.new('{this'),
          N::Text.new('is', :pre_blank => true),
          N::Text.new('last-text}.', :pre_blank => true)
        )
      )
    ) 
  end
  include_context 'parse example set'
end
