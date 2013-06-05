shared_context 'parse example set' do
  def parse
    KtouthBrand::ST2::PieceReader.parse(@source).each.to_a
  end
  it { parse.size.should == @pieces.size }

  it "piece check" do
    parse.zip(@pieces).each_with_index do |(piece, example), index|
      piece.should be_valid_piece(index, example)
    end
  end
end

RSpec::Matchers.define :be_valid_piece do |index, other|
  match do |player|
    raise ArgumentError, 'other is invalid array' unless other.is_a?(Array) && (other.size == 4)
    if player.is_a?(KtouthBrand::ST2::Piece)
      ary = [:token, :lineno, :column, :value].map {|x| player.send(x) }
      ary.zip(other).all? {|a, b| a == b }
    end
  end

  failure_message_for_should do |player|
    ary = player.is_a?(KtouthBrand::ST2::Piece) ? [:token, :lineno, :column, :value].map {|x| player.send(x) } : player
    "\nexpected: [#{index}]#{other.inspect}\n     got: [#{index}]#{ary.inspect}\n"
  end
end