class Minesweeper

    def initialize
    @BOMBS = 10
    @X_DIM = 9
    @Y_DIM = 9
    @grid = Array.new(@Y_DIM) { Array.new(@X_DIM) }

  end

  # private

    def seed_grid
      @BOMBS.times do
        bomb_placed = false
        until bomb_placed
          y_loc = rand(@Y_DIM)
          x_loc = rand(@X_DIM)
          unless @grid[y_loc][x_loc]
            @grid[y_loc][x_loc] = :bomb
            bomb_placed = true
          end
        end
      end

      @grid
    end
end
