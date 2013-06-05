require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../parse_specset')

describe "Matcher #be_valid_piece" do
  valid_value = KtouthBrand::ST2::Piece.send(:new, :sample, 1, 14, "test")
  invalid_value = KtouthBrand::ST2::Piece.send(:new, :test, 5, 4, "invalid")
  match_value = [:sample, 1, 14, "test"]
  
  describe "expect(actual).to be_valid_piece(expected)" do
    it "passes if actual is matched array values" do
      expect(valid_value).to be_valid_piece(2, match_value)
    end

    it "fails if actual is matched array values" do
      expect {
        expect(valid_value).to be_valid_piece(2, [:invalid, 11, 12, nil])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, %Q{\nexpected: [2][:invalid, 11, 12, nil]\n     got: [2][:sample, 1, 14, "test"]\n})
    end

    it "fails if match-value is invalid array" do
      expect { expect(valid_value).to be_valid_piece(2, 156323) }.to raise_error
      expect { expect(valid_value).to be_valid_piece(2, nil) }.to raise_error
      expect { expect(valid_value).to be_valid_piece(2, []) }.to raise_error
    end
  end
end
