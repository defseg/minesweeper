class Tile

  attr_accessor :number, :flagged, :bombed

  def initialize
    @number = nil
    @flagged = false
    @bombed = false
  end

  def revealed?
    !!@number
  end

  def flag
    @flagged = true
  end

end

class Board

  def initialize
    @BOMBS = 10
    @X_DIM = 9
    @Y_DIM = 9
    @grid = Array.new(@Y_DIM) { Array.new(@X_DIM) { Tile.new } }
    seed_grid
  end

  def flag_tile(y, x)
    if @grid[y][x].number == nil || @grid[y][x].bombed
      @grid[y][x].flagged = true
    else
      raise "Can't flag a numbered square"
    end
  end

  def reveal_square(y, x)
    # check if it's already been revealed
    # check if it's a bomb
    # if not, get its number
    # if it's zero, go through each adjacent tile and reveal_square it recursively
  end

  private

    def seed_grid
      @BOMBS.times do
        bomb_placed = false
        until bomb_placed
          y_loc = rand(@Y_DIM)
          x_loc = rand(@X_DIM)
          unless @grid[y_loc][x_loc].bombed
            @grid[y_loc][x_loc].bombed = true
            bomb_placed = true
          end
        end
      end
    end

    def get_neighbors(y, x)
      DELTAS = [-1, 0, 1].repeated_permutation(2).to_a

      neighbors = []
      DELTAS.each do |delta|
        delta_y, delta_x = delta
        new_y = y + delta_y
        new_x = x + delta_x
        neighbors << @grid[new_y][new_x] if valid_square?(new_y, new_x)
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

  def get_user_input
    puts "Pick a square. Input your choice in the format row,column."
    puts "Prefix your choice with r to reveal or f to flag."
    #r3,7 or f0,0 etc.

    user_input = gets.chomp

    if user_input[0] = 'r'
      user_action = :reveal
    elsif user_input[0] = 'f'
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
end
