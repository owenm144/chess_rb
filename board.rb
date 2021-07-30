require_relative 'pieces'
require_relative 'utils'

class Board
  attr_reader :data
  def initialize(state = StartState)
    @data = Array.new(8) { Array.new(8) }
    set_data(state)
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

  # return true if the input color is in check
  def in_check?(color)
    king = get_pieces(color, King)[0]
    return false if king.nil?

    other_color = color == :white ? :black : :white
    enemy_pieces = get_pieces(other_color)
    #king_pos = get_pieces(color, King)[0].pos
    enemy_pieces.any? { |piece| piece.moves.include?(king.pos) }
  end

  # return true if the input color is in checkmate
  def in_checkmate?(color)
    pieces = get_pieces(color)
    pieces.all? { |piece| piece.valid_moves.none? }
  end

  # set the board state data using an FEN string
  def set_data(input)

    # clear existing data
    @data.each do |x|
      x.clear
    end

    # process each character in the first string
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

    # check various error states; order is important here!
    return "Error: selected position invalid" if Board.on_board?(from) == false
    return "Error: board space is empty" if self[from].nil?
    return "Error: selected piece belongs to opponent" if self[from].color != color
    return 'Error: targeted position invalid' if Board.on_board?(to) == false
    return "Error: piece cannot move to the space it currently occupies" if from == to
    
    if self[from].valid_moves.include?(to) == false
      return "Error: move would result in check" if self[from].move_make_check?(to)
      return "Error: you are currently in check" if self.in_check?(color)
      return "Error: selected move cannot be performed"
    end

    # if no error found, return valid
    return "valid"
  end

  # prints the board state to the terminal
  def print_data
    
    # begin at [0, 7]
    7.downto(-1) do |y|
      -1.upto(7) do |x|

        # print row numbers
        if x == -1
          print "#{y + 1} | " if y >= 0
          print "".ljust(3) if y < 0
          next
        end
        
        # print column letters
        if y == -1
          print " " + %w[a b c d e f g h][x].to_s if x >= 0
          next
        end

        # print piece symbols
        pos = [x, y]
        print self[pos].nil? ? "- " : "#{self[pos].symbol} "
      end
      print "\n"
    end
    print "\n"
  end

  # returns a copy of this board
  def copy_board

    # create an empty copy of the board
    copy = Board.new(EmptyState)

    # copy the data to the new board
    (0..7).each do |x|
      (0..7).each do |y|

        pos = [x, y]
        piece = self[pos]
        next if piece.nil?

        copy[pos] = piece.class.new(copy, pos, piece.color)
      end
    end

    return copy
  end
end
