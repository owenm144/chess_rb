require_relative 'board'
require_relative 'pieces'
require_relative 'utils'
require 'colorize'

class Game
  attr_accessor :board, :history, :active_player
  def initialize(state = StartState)
    @board = Board.new(state)
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
    puts "\nBegin Game!".green.bold

    # enter main loop
    while true
      @board.print_data
      take_turn

      # increment halfmove and fullmove counters
      @halfmoves += 1
      @fullmoves += 1 if @halfmoves % 2 == 0

      # check if the other player is in checkmate
      end_game if @board.in_checkmate?(inactive_player)

      # swap player turn
      @active_player = inactive_player
    end
  end

  # process a turn for the current player
  def take_turn
    while true do

      # request input from the player
      print "#{"Enter".green.bold} #{format(active_player)}#{"'s Move:".green.bold} "
      input = gets.chomp
      
      # handle quit and undo messages
      if input == "q"
        exit
      elsif input == "undo"
        undo_move ? return : next
      elsif input == "fen"
        board.write_fen; next
      end

      # convert input string to move
      from, to = input_to_move(input)
      
      # output error message if input was too short
      if from == nil || to == nil
        puts "#{"Error:".red.bold} input not sufficient", ""; next
      end

      # return move if valid, or output error message
      validity = @board.query_move(active_player, from, to)
      if validity == "valid"
        @history.push([from, to, board[to]])
        @board.move_piece(from, to)
        puts "#{format(active_player)} moves #{@board[to].class.to_s.bold} from #{index_to_an(from)} to #{index_to_an(to)}"
        print_check_state
        return
      else
        puts validity; next
      end
    end
  end

  # undo the last move made this game
  def undo_move
    if @history.empty?
      puts "No moves to undo", ""
      return false
    else
      from, to, take = @history.pop
      @board.move_piece(to, from)          
      @board[to] = take
      puts "#{format(inactive_player)} moves #{@board[from].class.to_s.bold} from #{index_to_an(to)} back to #{index_to_an(from)}"
      print_check_state
      return true
    end
  end

  # print a message if the inactive player is in check or checkmate
  def print_check_state
    if @board.in_check?(inactive_player)
      state = @board.in_checkmate?(inactive_player) ? 'checkmate!' : 'check!'
      puts "#{format(inactive_player)} in #{state.red.bold}"
    end
  end

  # end the game with the winning color
  def end_game
    puts "\n#{format(active_player)} Wins!"

    # request input for what to do next
    while true
      puts "Play again? (y/n):"

      case gets.chomp
        when "n" || "no"
          exit
        when "y" || "yes"
          load_game_state(StartState)
          self.play
        else
          puts "Command not recognised"
      end
    end
  end

  # load a game state using FEN-notation
  def load_game_state(input)

    if (File.exist?(input))
      input = File.open(input).read
    end

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

  def save_game_state
    file = File.new("save.txt", "w")
    file.write(board.write_fen)
    file.close
  end
end

game = Game.new
game.load_game_state("save.txt")
game.play