class Tile

  attr_accessor :revealed, :number, :flagged, :bombed

  def initialize(bombed)
    @revealed = false
    @number = nil
    @flagged = false
    @bombed = bombed
  end

  def flag
    @flagged = true
  end

end

class Board

  def initialize

  end

end

class Minesweeper

    def initialize
      @BOMBS = 10
      @X_DIM = 9
      @Y_DIM = 9
      @grid = Array.new(@Y_DIM) { Array.new(@X_DIM) { [nil, false]} }
      seed_grid
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
        if @grid[user_y][user_x][0] == nil || @grid[user_y][user_x][0] == :bomb
          @grid[user_y][user_x][1] = true
        else
          raise "Can't flag a numbered square"
        end
      elsif user_action == :reveal
        reveal_square(user_y, user_x)
      end
    end

  private

    def reveal_square(y, x)

    end

    def seed_grid
      @BOMBS.times do
        bomb_placed = false
        until bomb_placed
          y_loc = rand(@Y_DIM)
          x_loc = rand(@X_DIM)
          unless @grid[y_loc][x_loc][0]
            @grid[y_loc][x_loc][0] = :bomb
            bomb_placed = true
          end
        end
      end

      @grid
    end
end
