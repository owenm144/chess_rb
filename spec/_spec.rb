require_relative '../board'
require_relative '../utils'

describe Board do

	it "should detect a check condition" do
		board = Board.new
		board.set_data(CheckState)
		expect(board.in_check? :black).to be true
	end

	it "should detect a checkmate condition" do
		board = Board.new
		board.set_data(CheckmateState)
		expect(board.in_checkmate? :black).to be true
	end

	# test undo
	# test 
	end
end