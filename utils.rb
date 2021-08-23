StartState = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
CloseState = "8/8/rnbqkbnr/pppppppp/PPPPPPPP/RNBQKBNR/8/8 w KQkq - 0 1"
CheckState = "7k/8/8/7R/8/8/8/8 w KQkq - 0 1"
CheckmateState = "7k/8/6R1/7R/8/8/8/8 w KQkq - 0 1"
EmptyState = "8/8/8/8/8/8/8/8 w KQkq - 0 1"
CornerState = "k6q/8/8/8/8/8/8/K6Q w KQkq - 0 1"

# return a formatted string for a player color
def format(color)
  string = color.to_s.capitalize.bold
  string = color == :white ? string.white : string.light_black
end

# convert input string to move
def input_to_move(input)
	return nil if input.length < 4
	from = an_to_index([input[0], input[1]])
  to = an_to_index([input[-2], input[-1]])
	return [from, to]
end

# convert between algebraic notation and board index
def an_to_index(input)
  x = 8 - input[1].to_i
  y = (input[0].ord - 49).chr.to_i
  [x, y]
end
def index_to_an(input)
  x = 8 - input[1]
  y = (input[0].to_s.ord + 49).chr
  "#{x}#{y}"
end