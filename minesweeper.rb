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
      if user_action == :flag
        #do flag function
      else
        #do reveal function
      end
    end

  private

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
