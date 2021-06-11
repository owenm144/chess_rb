require_relative 'board'
require_relative 'pieces'

class Game
  attr_reader :board
  def initialize()
    @board = Board.new(false)
    @player_turn = :white
  end
  def play
    puts "Begin Game!"
    while true
      take_turn(@player_turn)
      other_color = @player_turn == :white ? :black : :white
      if @board.in_checkmate?(other_color)
        board.print_board
        puts "#{other_color == :white ? "White" : "Black"} Wins!"
      end
      @player_turn = @player_turn == :white ? :black : :white
    end
  end

  def take_turn(color)
    @board.print_board
    print "\nEnter #{ color == :white ? "White's " : "Black's "} Move: "

    from, to = get_move(color)
    @board.move_piece(from, to)
    puts "#{ color == :white ? "White " : "Black "} moves from #{from} to #{to}"
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

  def load_FEM(input)
    fields = input.split(" ") # get the six fields of the FEM code

    # load board state using first field
    x_index = 0
    y_index = 7
    pieces = []

    fields[0].split("").each do |char|
      case char.ord
        when (48..57) # 0..9
          x_index += char.ord - 48
          next
        when 47 # "/"
          x_index = 0
          y_index -= 1
          next
        when 80 # "P"
          pieces.push(Pawn.new(self, [x_index, y_index], :white))
        when 112 # "p"
          pieces.push(Pawn.new(self, [x_index, y_index], :black))
        when 82 # "R"
          pieces.push(Rook.new(self, [x_index, y_index], :white))
        when 114 # "r"
          pieces.push(Rook.new(self, [x_index, y_index], :black))
        when 78 # "N"
          pieces.push(Knight.new(self, [x_index, y_index], :white))
        when 110 # "n"
          pieces.push(Knight.new(self, [x_index, y_index], :black))
        when 66 # "B"
          pieces.push(Bishop.new(self, [x_index, y_index], :white))
        when 98 # "b"
          pieces.push(Bishop.new(self, [x_index, y_index], :black))
        when 81 # "Q"
          pieces.push(Queen.new(self, [x_index, y_index], :white))
        when 113 # "q"
          pieces.push(Queen.new(self, [x_index, y_index], :black))
        when 75 # "K"
          pieces.push(King.new(self, [x_index, y_index], :white))
        when 107 # "k"
          pieces.push(King.new(self, [x_index, y_index], :black))
      end
      x_index += 1
    end
    pieces.each do |piece| # add each piece to the board
      index = piece.pos
      puts "Index: #{index}"
      @board[index] = piece
    end

    # set current player turn
    @player_turn = :white if fields[1] == "w"
    @player_turn = :black if fields[1] == "b"


  end
end

# start = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
game = Game.new
game.load_FEM("8/8/8/4p1K1/2k1P3/8/8/8 b - - 0 1")
game.play
