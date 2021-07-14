require_relative 'board'
require_relative 'pieces'

class Game
  attr_reader :board
  def initialize
    @board = Board.new
    @player_turn = :white
    @halfmoves = 0
    @fullmoves = 0
    @castling = "KQkq"
    @en_passant = [-1, -1] # when a pawn moves two squares, set this to the position behind them, an enemy pawn can move diagonally to this square
  end

  # begin a new game of chess
  def play
    puts "\nBegin Game!"
    @board.print_data

    # enter main loop
    while true
      take_turn(@player_turn)
      @board.print_data

      # check if the other player is in checkmate
      other_color = @player_turn == :white ? :black : :white
      if @board.in_checkmate?(other_color)
        end_game(other_color)
      end

      # swap player turn
      @player_turn = other_color
    end
  end

  # get a player colors turn
  def take_turn(color)

    # get a legal move and move a piece
    from, to = get_move(color)
    @board.move_piece(from, to)
    puts "#{color == :white ? "White" : "Black"} moves #{@board[to].class.to_s} from #{index_to_an(from)} to #{index_to_an(to)}", ""
  
    # increment halfmove and fullmove counters
    @halfmoves += 1
    @fullmoves += 1 if @halfmoves % 2 == 0
  end

  # get user input and verify the move is legal
  def get_move(color)

    while true do
      print "\nEnter #{color == :white ? "White" : "Black"}'s Move: "
      input = gets.chomp
      
      # stop program if input is an exit command
      exit if %w[exit quit stop q].include?(input)

      # output error message if input was too short
      if input.length < 4
        puts "Input Error: input.length was < 4"
        next
      end

      # convert input from algebraic notation to board indices
      from = an_to_index([input[0], input[1]])
      to = an_to_index([input[-2], input[-1]])

      # return move if valid, or output error message
      validity = @board.query_move(color, from, to)
      if validity == "valid"
        break
      else
        puts validity
      end
    end
    
    [from, to]
  end

  # display end of game text
  def end_game(color)
    
    puts "\n#{color == :white ? "White" : "Black"} Wins!"

    while true
      puts "Play again? (y/n):"
      input = gets.chomp
      if input == "y"
        load_game_state("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
        self.play
      elsif input == "n"
        exit
      else
        puts "Command not recognised"
      end
    end
  end

  # load a game state using FEN-notation
  def load_game_state(input)

    # get the six fields of the FEN code
    fields = input.split(' ')

    # set the board state
    board.set_data(fields[0])

    # set current player turn
    @player_turn = :white if fields[1] == "w"
    @player_turn = :black if fields[1] == "b"

    # TODO: add other game state variables ie castling possibility
    @castling = fields[2]

  end
end

def an_to_index(input)
  x = (input[0].ord - 49).chr.to_i
  y = input[1].to_i - 1
  [x, y]
end
def index_to_an(input)
  x = (input[0].to_s.ord + 49).chr
  y = input[1] + 1
  "#{x}#{y}"
end

game = Game.new
game.play
