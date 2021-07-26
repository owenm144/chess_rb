require_relative 'board'
require_relative 'pieces'
require_relative 'utils'
require 'colorize'

class Game
  attr_reader :board, :history
  attr_accessor :active_player

  def initialize
    @board = Board.new
    @active_player = :white
    @history = []
    @halfmoves = 0
    @fullmoves = 0
    @castling = "KQkq"
    @en_passant = [-1, -1] # when a pawn moves two squares, set this to the position behind them, an enemy pawn can move diagonally to this square
  end

  # return the player other than the active player
  def inactive_player
    return active_player == :white ? :black : :white
  end

  # begin a new game
  def play
    puts "\nBegin Game!\n".green.bold
    @board.print_data

    # enter main loop
    while true

      # take the current players turn and print the board state
      take_turn
      @board.print_data

      # increment halfmove and fullmove counters
      @halfmoves += 1
      @fullmoves += 1 if @halfmoves % 2 == 0

      # check if the other player is in checkmate
      if @board.in_checkmate?(inactive_player)
        end_game
      end

      # swap player turn
      @active_player = inactive_player
    end
  end

  # process a turn for the current player
  def take_turn

    # get a legal move and move a piece
    from, to = get_move
    @board.move_piece(from, to)
    puts "#{format(active_player)} moves #{@board[to].class.to_s.bold} from #{index_to_an(from)} to #{index_to_an(to)}", ""
    
    # check if the other player is in check or checkmate
    if @board.in_check?(inactive_player)
      state = @board.in_checkmate?(inactive_player) ? "checkmate!" : "check!"
      puts "#{format(inactive_player)} in #{state.red.bold}"
    end
  end

  # get user input and verify the move is legal
  def get_move
    while true do
      print "#{"Enter".light_green.bold} #{format(active_player)}#{"'s Move:".light_green.bold} "
      input = gets.chomp
      
      # handle quit game command
      exit if input == 'q'

      # handle undo command
      if input == 'undo'
        if @history.empty?
          puts "No moves to undo"
          next
        else
          from, to = @history.pop
          return [to, from]
        end
      end

      # convert input string to move
      from, to = input_to_move(input)
      
      # output error message if input was too short
      if from == nil || to == nil
        puts "Error: input not sufficient", ""
        next
      end

      # return move if valid, or output error message
      validity = @board.query_move(active_player, from, to)
      if validity == "valid"
        @history.push([from, to])
        return [from, to]
      else
        puts validity
      end
    end
  end

  # undoes the last move in the history
  def undo_move
    from, to = @history.pop

    puts "Undo called: last move was from #{from} to #{to}"
    board.move_piece(to, from)
  end

  # end the game with the winning color
  def end_game
    
    puts "\n#{format(active_player)} Wins!"

    while true
      puts "Play again? (y/n):"
      input = gets.chomp
      exit if input == "n"

      if input == "y"
        load_game_state(StartState)
        self.play
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
    active_player = :white if fields[1] == "w"
    active_player = :black if fields[1] == "b"

    # TODO: add other game state variables ie castling possibility
    @castling = fields[2]

  end
end

game = Game.new
#game.load_game_state("7k/8/6R1/6R1/8/8/8/8 w KQkq - 0 1")
game.play
