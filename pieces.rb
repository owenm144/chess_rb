require 'colorize'

class Piece
  attr_accessor :board, :pos, :color, :moves, :symbol
  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @color = color
  end
  def inspect
    "#{ self.class }\t #{ color }, #{ pos }"
  end
  def moves
    raise NotImplementedError
  end

  # return an array containing all moves that will not result in check
  def valid_moves
    moves.select { |move| move_make_check?(move) == false }
  end

  # return true if the input move will result in check for this piece color
  def move_make_check?(move_pos)
    copy_board = board.copy_board
    copy_board.move_piece(self.pos, move_pos)
    copy_board.in_check?(color)
  end

  # fill the move array with all valid moves in 
  def fill_steps(steps)

    @moves = []
    steps.each do |step|

      # add if space is on the board, and empty or contains a piece of the opposite color
      new_pos = pos[0] + step[0], pos[1] + step[1]
      @moves << new_pos if Board.on_board?(new_pos) && (board[new_pos].nil? || board[new_pos].color != self.color)
    end

    return @moves
  end

  # fill the move array with all valid moves in any number of spaces in input directions
  def fill_slides(directions)

    @moves = []
    directions.each do |dir|

      # get next space in direction
      new_pos = pos[0] + dir[0], pos[1] + dir[1]
      while Board.on_board?(new_pos)

        # add space if empty, or contains a piece of opposite color
        if board[new_pos].nil?
          @moves << new_pos
        else
          @moves << new_pos if board[new_pos].color != self.color
          break
        end

        # go to next space in direction
        new_pos = new_pos[0] + dir[0], new_pos[1] + dir[1]
      end
    end

    return @moves
  end
end

class Pawn < Piece
  attr_accessor :has_moved
  def initialize(board, pos, color)
    super
    @symbol = color == :white ? '♟︎'.white : '♙'.light_black.bold
    @has_moved = false
  end
  def pos=(pos)
    @pos = pos
    @has_moved = true
  end
  def moves
    @moves = []
    forward = color == :white ? 1 : -1 # forward direction of pawns

    # get one space in front, add if on the board and empty
    forward_one = pos[0], pos[1] + forward # maybe wrong element
    if Board.on_board?(forward_one) && board[forward_one].nil?
      @moves << forward_one

      # get two spaces in front, add if on the board, both forward spaces are empty, and piece has not moved
      if has_moved == false
        forward_two = pos[0], pos[1] + forward + forward # get two spaces forward
        @moves << forward_two if Board.on_board?(forward_two) && board[forward_two].nil?
      end
    end

    # get diagonal spaces if they contain a piece of the opposite color
    diagonals = [ [pos[0] - 1, pos[1] + forward], [pos[0] + 1, pos[1] + forward] ]
    diagonals.each do |diag|
      @moves << diag if Board.on_board?(diag) && !board[diag].nil? && board[diag].color != self.color
    end
    @moves
  end
end
class Rook < Piece
  def initialize(board, pos, color)
    super
    @symbol = color == :white ? '♜'.white : '♖'.light_black.bold
  end
  def moves
    fill_slides([[-1, 0], [1, 0], [0, -1], [0, 1]])
  end
end
class Knight < Piece
  def initialize(board, pos, color)
    super
    @symbol = color == :white ? '♞'.white : '♘'.light_black.bold
  end
  def moves
    fill_steps([[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]])
  end
end
class Bishop < Piece
  def initialize(board, pos, color)
    super
    @symbol = color == :white ? '♝'.white : '♗'.light_black.bold
  end
  def moves
    fill_slides([[-1, -1], [-1, 1], [1, -1], [1, 1]])
  end
end
class Queen < Piece
  def initialize(board, pos, color)
    super
    @symbol = color == :white ? '♛'.white : '♕'.light_black.bold
  end
  def moves
    fill_slides([[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]])
  end
end
class King < Piece
  def initialize(board, pos, color)
    super
    @symbol = color == :white ? '♚'.white : '♔'.light_black.bold
  end
  def moves
    fill_steps([[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]])
  end
end
