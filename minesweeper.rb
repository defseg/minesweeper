class Tile

  attr_accessor :number, :flagged, :bomb, :revealed

  def initialize
    @number = nil
    @flagged = false
    @bomb = false
    @revealed = false
  end

  def flag
    @flagged = !@flagged
  end

end

class Board
  attr_reader :grid

  def initialize
    @BOMBS = 10
    @X_DIM = 9
    @Y_DIM = 9
    @grid = Array.new(@Y_DIM) { Array.new(@X_DIM) { Tile.new } }
    seed_grid
  end

  def flag_tile(y, x)
    if @grid[y][x].number == nil || @grid[y][x].bomb
      @grid[y][x].flag
    else
      raise "Can't flag a numbered square"
    end
  end

  def reveal_tile(y, x)
    tile = @grid[y][x]
    # check if it's already been revealed
    return :reveal if tile.revealed

    # check if it's a bomb
    return :lose if tile.bomb

    # if not, get its number
    neighbors = get_neighbors(y, x)
    bomb_count = 0
    neighbor_tiles(neighbors).each do |neighbor|
      bomb_count += 1 if neighbor.bomb
    end
    # if it's zero, go through each adjacent tile and reveal_square it recursively
    tile.number = bomb_count
    tile.revealed = true unless tile.flagged
    if bomb_count == 0
      neighbors.each do |neighbor|
        neighbor_y, neighbor_x = neighbor
        reveal_tile(neighbor_y, neighbor_x) unless @grid[neighbor_y][neighbor_x].flagged
      end
    end
  end

  private

    def neighbor_tiles(coord_array)
      coord_array.map do |coords|
        new_y, new_x = coords
        @grid[new_y][new_x]
      end
    end

    def seed_grid
      @BOMBS.times do
        bomb_placed = false
        until bomb_placed
          y_loc = rand(@Y_DIM)
          x_loc = rand(@X_DIM)
          unless @grid[y_loc][x_loc].bomb
            @grid[y_loc][x_loc].bomb = true
            bomb_placed = true
          end
        end
      end
    end

    def get_neighbors(y, x)
      deltas = [-1, 0, 1].repeated_permutation(2).to_a

      neighbors = []
      deltas.each do |delta|
        delta_y, delta_x = delta
        new_y = y + delta_y
        new_x = x + delta_x
        neighbors << [new_y, new_x] if valid_square?(new_y, new_x)
      end

      neighbors
    end

    def valid_square?(y, x)
      y.between?(0, @Y_DIM-1) && x.between?(0, @X_DIM-1)
    end

end

class Minesweeper

  def initialize
    @board = Board.new
  end

  def play
    game_over = false
    until game_over
      user_input = get_user_input
      user_y, user_x = user_input[1]
      p user_input
      if user_input[0] == :flag
        @board.flag_tile(user_y, user_x)
      elsif user_input[0] == :reveal
        @board.reveal_tile(user_y, user_x)
      end
      # TODO write test on Board to see if the game is over and if it's won or lost
    end
  end

  def get_user_input
    puts "Board:"
    display_board
    puts "Pick a square. Input your choice in the format row,column."
    puts "Prefix your choice with r to reveal or f to flag."
    #r3,7 or f0,0 etc.

    user_input = gets.chomp

    if user_input[0] == 'r'
      user_action = :reveal
    elsif user_input[0] == 'f'
      user_action = :flag
    else
      raise "Invalid input"
    end

    # TODO add error-checking to make sure the coords are valid
    user_coordinates = user_input[1..-1].split(',').map(&:to_i)

    [user_action, user_coordinates]
  end

  def execute_user_action(user_action, user_coordinates) # auto-decompose array
    user_y, user_x = user_coordinates
    if user_action == :flag
      @board.flag(user_y, user_x)
    elsif user_action == :reveal
      @board.reveal_square(user_y, user_x)
    end
  end

  def display_board
    board_array = @board.grid #to-do refactor this later

    board_array.each do |row|
      row.each do |tile|
        if tile.revealed
          print tile.number == 0 ? "_" : tile.number
        elsif tile.flagged
          print "F"
        else
          if tile.bomb
            print "*"
          else
            print "."
          end
        end
      end
      puts ""
    end
  end

  def display_board_loss
    board_array = @board.grid #to-do refactor this later

    board_array.each do |row|
      row.each do |tile|
        if tile.number
          print tile.number == 0 ? "_" : tile.number
        else
          if tile.bomb
            print "*"
          else
            print "."
          end
        end
      end
      puts ""
    end
  end
end
