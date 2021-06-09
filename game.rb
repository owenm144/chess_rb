require_relative 'board'
require_relative 'pieces'

class Game
  attr_reader :board
  def initialize
    @board = Board.new
  end
  def play
    puts "Begin Game!"
    while true
      board.print_board
      take_turn(:white)
      if @board.in_checkmate?(:black)
        board.print_board
        puts "White Wins!"
        return
      end
      board.print_board
      take_turn(:black)
      if @board.in_checkmate?(:white)
        board.print_board
        puts "Black Wins!"
        return
      end
    end
  end

  def take_turn(color)
      print "\nEnter #{ color == :white ? "White's " : "Black's "} Move: "

      from, to = get_move(color)
      @board.move_piece(from, to)
      puts "#{ color == :white ? "White " : "Black "} moves from #{from} to #{to}"
  end
end

def input_to_coord(input)
  letter_num = {
    "a" => 0,
    "b" => 1,
    "c" => 2,
    "d" => 3,
    "e" => 4,
    "f" => 5,
    "g" => 6,
    "h" => 7
  }
  return [letter_num[input[0]], input[1].to_i - 1]
end

def get_move(color)
  while true do
    input = gets.chomp
    exit if input == "exit"

    from = input_to_coord([input[0], input[1]])
    to = input_to_coord([input[-2], input[-1]])
    puts "Move piece from #{from} to #{to}"
    if Board.on_board?(from) && Board.on_board?(to)
      if @board[from].nil? == false && @board[from].color == color && @board[from].valid_moves.include?(to)
        break
      end
    end
    puts "input invalid"
  end
  return [from, to]
end

game = Game.new
game.play
