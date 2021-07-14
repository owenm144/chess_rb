require_relative 'pieces'

class Board
  attr_reader :data
  def initialize(set = true)
    @data = Array.new(8) { Array.new(8) }
    reset if set
  end

  # get and set data
  def [](pos)
    row, col = pos
    @data[row][col]
  end
  def []=(pos, piece)
    row, col = pos
    @data[row][col] = piece
  end

  # return true if the position is within range 0..7
  def self.on_board?(pos)
    (0..7).include?(pos[0]) && (0..7).include?(pos[1])
  end

  # return an array containing pieces of input color and type
  def get_pieces(color, type = Piece)
    pieces = @data.flatten.compact.select do |piece|
      piece.color == color && piece.is_a?(type)
    end
  end

  # clear the board
  def clear_data
    @data.each do |x|
      x.clear
    end
  end

  # reset the board to the initial state
  def reset
    set_data("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  end

  # return true if the input color is in check
  def in_check?(color)
    other_color = color == :white ? :black : :white
    enemy_pieces = get_pieces(other_color)
    king_pos = get_pieces(color, King)[0].pos
    enemy_pieces.any? { |piece| piece.moves.include?(king_pos) }
  end

  # return true if the input color is in checkmate
  def in_checkmate?(color)
    pieces = get_pieces(color)
    pieces.all? { |piece| piece.valid_moves.none? }
  end

  # set the board state data using an FEN string
  def set_data(input)

    # clear existing data and process each character in the string
    self.clear_data
    pieces = []
    x_index, y_index = 0, 7
    input = input.split(' ')[0]
    input.split('').each do |char|

      # char ascii value in range 0..9
      if (48..57).include?(char.ord)
        x_index += char.ord - 48
        next
      else
        case char
          when "/"
            x_index = 0
            y_index -= 1
            next
          when "P"
            pieces.push(Pawn.new(self, [x_index, y_index], :white))
          when "p"
            pieces.push(Pawn.new(self, [x_index, y_index], :black))
          when "R"
            pieces.push(Rook.new(self, [x_index, y_index], :white))
          when "r"
            pieces.push(Rook.new(self, [x_index, y_index], :black))
          when "N"
            pieces.push(Knight.new(self, [x_index, y_index], :white))
          when "n"
            pieces.push(Knight.new(self, [x_index, y_index], :black))
          when "B"
            pieces.push(Bishop.new(self, [x_index, y_index], :white))
          when "b"
            pieces.push(Bishop.new(self, [x_index, y_index], :black))
          when "Q"
            pieces.push(Queen.new(self, [x_index, y_index], :white))
          when "q"
            pieces.push(Queen.new(self, [x_index, y_index], :black))
          when "K"
            pieces.push(King.new(self, [x_index, y_index], :white))
          when "k"
            pieces.push(King.new(self, [x_index, y_index], :black))
        end
        x_index += 1
      end
    end

    # add each piece to the board
    pieces.each do |piece|
      index = piece.pos
      self[index] = piece
    end
  end

  # move a piece from one position to another
  def move_piece(from, to)
    piece = self[from]
    return if piece.nil?

    piece.pos = to
    self[to] = piece
    self[from] = nil
  end

  # return an explanation of the validity of the move
  def query_move(color, from, to)

    if Board.on_board?(from) == false || Board.on_board?(to) == false
      return "Move Error: position not on board"
    end
    if self[from].nil?
      return "Move Error: board space is empty"
    end
    if self[from].color != color
      return "Move Error: selected piece is not correct color"
    end
    if self[from].valid_moves.include?(to) == false
      return "Move Error: move would result in check" if self[from].move_make_check?(to)
      return "Move Error: you are currently in check" if self.in_check?(color)
      return "Move Error: selected move is invalid"
    end

    return "valid"
  end

  # prints the board state to the terminal
  def print_data
    
    column_labels = %w[a b c d e f g h]
    7.downto(-1) do |y| # each column
      -1.upto(7) do |x| # each row

        if x == -1 # print row numbers
          print "#{y + 1} | " if y >= 0
          print "".ljust(3) if y < 0
          next
        end
        if y == -1 # print column letters
          print " " + column_labels[x].to_s if x >= 0
          next
        end

        # print piece symbols
        pos = [x, y]
        if self[pos].nil?
          print "- "
        else
          print "#{self[pos].symbol} "
        end
      end
      print "\n"
    end
  end

  # returns a copy of this board
  def copy_board

    copy = Board.new(false)
    (0..7).each do |row_index|
      (0..7).each do |col_index|

        pos = [row_index, col_index]
        piece = self[pos]
        next if piece.nil?

        copy[pos] = piece.class.new(copy, pos, piece.color)
      end
    end

    copy
  end
end
