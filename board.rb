require_relative 'pieces'

class Board
  attr_reader :data
  def initialize(setup = true)
    @data = Array.new(8) { Array.new(8) }
    reset_pieces if setup
  end

  # getter for data array
  def [](pos)
    row, col = pos
    @data[row][col]
  end

  # setter for data array
  def []=(pos, piece)
    row, col = pos
    @data[row][col] = piece
  end

  def self.on_board?(pos)
    (0..7).include?(pos[0]) && (0..7).include?(pos[1]) # return true if position lies in range 0..7
  end

  # return true if the input color is in check
  def in_check?(color)
    other_color = color == :white ? :black : :white
    enemy_pieces = get_pieces(other_color)          # get pieces of the opposite color
    king_pos = get_pieces(color, King)[0].pos       # get king position
    enemy_pieces.any? do |piece|                    # return true if any enemy pieces can move to king position
      piece.moves.include?(king_pos)
    end
  end

  # return true if the input color is in checkmate
  def in_checkmate?(color)
    pieces = get_pieces(color)                      # get pieces of color
    pieces.all? { |piece| piece.valid_moves.none? } # return true if all pieces have no valid moves
  end

  def reset_pieces
    pieces = [ # create pieces
      Rook.new(self,   [0, 0], :white), # 7 [♖] [♘] [♗] [♕] [♔] [♗] [♘] [♖]
      Knight.new(self, [1, 0], :white), # 6 [♙] [♙] [♙] [♙] [♙] [♙] [♙] [♙]
      Bishop.new(self, [2, 0], :white), # 5 [  ] [  ] [  ] [ ] [ ] [  ] [  ] [  ]
      Queen.new(self,  [3, 0], :white), # 4 [  ] [  ] [  ] [ ] [ ] [  ] [  ] [  ]
      King.new(self,   [4, 0], :white), # 3 [  ] [  ] [  ] [ ] [ ] [  ] [  ] [  ]
      Bishop.new(self, [5, 0], :white), # 2 [  ] [  ] [  ] [ ] [ ] [  ] [  ] [  ]->[7, 2]
      Knight.new(self, [6, 0], :white), # 1 [♟︎] [♟︎] [♟︎] [♟︎] [♟︎] [♟︎] [♟︎] [♟︎]
      Rook.new(self,   [7, 0], :white), # 0 [♜] [♞] [♝] [♛] [♚] [♝] [♞] [♜]
      Rook.new(self,   [0, 7], :black), #    0    1    2    3   4    5    6    7
      Knight.new(self, [1, 7], :black),
      Bishop.new(self, [2, 7], :black),
      Queen.new(self,  [3, 7], :black),
      King.new(self,   [4, 7], :black),
      Bishop.new(self, [5, 7], :black),
      Knight.new(self, [6, 7], :black),
      Rook.new(self,   [7, 7], :black)
    ]

    (0..7).each do |index| # create pawns
      pieces.push(Pawn.new(self, [index, 1], :white))
      pieces.push(Pawn.new(self, [index, 6], :black))
    end

    pieces.each do |piece| # add each piece to the board
      index = piece.pos
      self[index] = piece
    end
  end

  # return an array containing all pieces of input color and type
  def get_pieces(color, type = Piece)
    pieces = data.flatten.compact.select do |piece|
      piece.color == color
    end
    pieces.select { |piece| piece.is_a?(type) } if type != Piece.class # select pieces of input type
  end

  # move the piece at the from position to the to position
  def move_piece(from, to)
    piece = self[from] # get piece at position
    piece.pos = to # move piece to new position
    self[to] = piece
    self[from] = nil
    true
  end

  def print_board
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

        pos = [x, y] # print piece symbols
        if self[pos].nil?
          print "- "
        else
          print "#{self[pos].symbol} "
        end
      end
      print "\n"
    end
  end

  def copy_board
    copy = Board.new(false)

    (0..7).each do |row_index|
      (0..7).each do |col_index|
        pos = [row_index, col_index]
        next if self[pos].nil?

        piece = self[pos]
        color = piece.color
        dup_piece = piece.class.new(copy, pos, color)

        copy[pos] = dup_piece
      end
    end
    copy
  end
end

board = Board.new
#board.load_FEM("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
#board.print_board
