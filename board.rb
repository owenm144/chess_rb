require_relative 'pieces'
require_relative 'utils'
require 'colorize'

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
    data.each { |x| x.fill(nil) }
    pieces = []
    row_index, col_index = 0, 0
    input = input.split(' ')[0]

    # process each row
    input.split("/").each do |row|
      row.split("").each do |char|

        if (48..57).include?(char.ord)
          col_index += char.ord - 48; next
        end

        pos = [row_index, col_index]
        case char
          when "P" then pieces.push(Pawn.new   self, pos, :white)
          when "p" then pieces.push(Pawn.new   self, pos, :black)
          when "R" then pieces.push(Rook.new   self, pos, :white)
          when "r" then pieces.push(Rook.new   self, pos, :black)
          when "N" then pieces.push(Knight.new self, pos, :white)
          when "n" then pieces.push(Knight.new self, pos, :black)
          when "B" then pieces.push(Bishop.new self, pos, :white)
          when "b" then pieces.push(Bishop.new self, pos, :black)
          when "Q" then pieces.push(Queen.new  self, pos, :white)
          when "q" then pieces.push(Queen.new  self, pos, :black)
          when "K" then pieces.push(King.new   self, pos, :white)
          when "k" then pieces.push(King.new   self, pos, :black)
        end

        col_index += 1
      end
      
      col_index = 0
      row_index += 1
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

  # return "valid" if move is legal, or an error message
  def query_move(color, from, to)

    # check for various errors; order is important here!
    return "#{"Error:".red.bold} selected space is invalid"                 if Board.on_board?(from) == false
    return "#{"Error:".red.bold} selected space is empty"                   if self[from].nil?
    return "#{"Error:".red.bold} selected piece belongs to opponent"        if self[from].color != color
    return "#{"Error:".red.bold} targeted space is invalid"                 if Board.on_board?(to) == false
    return "#{"Error:".red.bold} targeted space occupied by friendly piece" if self[to].nil? == false && self[to].color == color
    return "#{"Error:".red.bold} piece must move to a different space"      if from == to
    return "#{"Error:".red.bold} you are currently in #{"check!".red.bold}" if self.in_check?(color) && self[from].move_make_check?(to)
    return "#{"Error:".red.bold} move would result in #{'check!'.red.bold}" if self[from].move_make_check?(to)
    return "#{"Error:".red.bold} selected move cannot be performed"         if self[from].valid_moves.include?(to) == false
    return "valid"
  end

  # prints the board state to the terminal
  def print_data

    puts ""
    -1.upto(8) do |y|
      -1.upto(8) do |x|

        # print row numbers
        if x == -1
          print (0..7).include?(y) ? "#{8 - y} | ".green.bold : "".ljust(3); next
        elsif x == 8
          print (0..7).include?(y) ? " | #{8 - y}".green.bold : "".ljust(3); next
        end
        
        # print column letters
        if (0..7).include?(y) == false
          print " " + %w[a b c d e f g h][x].to_s.green.bold; next
        end

        # print piece symbol
        pos = [y, x]
        print self[pos].nil? ? "- " : "#{self[pos].symbol} "
      end
      print "\n"
    end
    print "\n"
  end

  # returns a copy of this board
  def copy_board

    # copy the data to a new board
    copy = Board.new(EmptyState)
    (0..7).each do |x|
      (0..7).each do |y|
        pos = [x, y]
        piece = self[pos]

        next if piece.nil?
        copy[pos] = piece.class.new(copy, pos, piece.color)
      end
    end
    copy
  end

  # returns a string of the FEN notation of the board state
  def write_fen
    fenstring = ""
    
    data.each do |row|
      rowstring = ""
      space_count = 0

      row.each do |piece|
        
        if piece.nil?
          space_count += 1
        else
          rowstring << space_count.to_s if space_count > 0
          space_count = 0

          rowstring += piece.color == :white ? "P" : "p" if piece.class == Pawn
          rowstring += piece.color == :white ? "R" : "r" if piece.class == Rook
          rowstring += piece.color == :white ? "N" : "n" if piece.class == Knight
          rowstring += piece.color == :white ? "B" : "b" if piece.class == Bishop
          rowstring += piece.color == :white ? "Q" : "q" if piece.class == Queen
          rowstring += piece.color == :white ? "K" : "k" if piece.class == King
        end
      end

      fenstring << rowstring
      fenstring << space_count.to_s if space_count > 0
      fenstring << "/" if row != data.last
    end

    puts fenstring
    fenstring
  end
end