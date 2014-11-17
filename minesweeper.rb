require 'yaml'

class Tile

  attr_accessor :flagged, :bomb, :revealed


  # the tile needs to know its coordinates
  # and calculate its number on the fly

  def flagged?
    @flagged
  end

  def initialize(board, position)
    @flagged = false
    @bomb = false
    @revealed = false
    @board = board
    @position = position
  end

  def toggle_flag
    @flagged = !@flagged
  end

  def number
    neighbors = get_neighbors
    bomb_count = 0
    neighbor_tiles(neighbors).each do |neighbor|
      bomb_count += 1 if neighbor.bomb
    end
    bomb_count
  end

  def reveal_tile
    return :reveal if revealed

    # check if it's a bomb
    return :lose if bomb

    # if not, get its number

    # if it's zero, go through each adjacent tile and reveal_square it recursively

    neighbors = get_neighbors
    @revealed = true unless flagged
    if self.number == 0
      neighbor_tiles(neighbors).each do |neighbor|
        neighbor.reveal_tile unless neighbor.flagged? || neighbor.revealed
      end
    end
  end

  def get_neighbors
    deltas = [-1, 0, 1].repeated_permutation(2).to_a

    neighbors = []
    deltas.each do |delta|
      delta_y, delta_x = delta
      new_y = @position[0] + delta_y
      new_x = @position[1] + delta_x
      neighbors << [new_y, new_x] if @board.valid_square?([new_y,new_x])
    end

    neighbors
  end

  def neighbor_tiles(coord_array)
    coord_array.map do |coords|
      @board[coords]
    end
  end

end

class Board
  attr_reader :grid

  def initialize
    @BOMBS = 10
    @X_DIM = 9
    @Y_DIM = 9
    @grid = Array.new(@Y_DIM) { Array.new(@X_DIM) }
    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        self[[y, x]] = Tile.new(self, [y, x])
      end
    end
    seed_grid
  end

  def flag_tile(pos)
    if !(self[pos].revealed) || self[pos].bomb
      self[pos].toggle_flag
    else
      raise "Can't flag a numbered square"
    end
  end

  def [](pos) # [0, 0]
    y, x = pos
    @grid[y][x]
  end

  def []=(pos, to_assign)
    y, x = pos
    @grid[y][x] = to_assign
  end

  def reveal_tile(y, x)
    tile = @grid[y][x]
    tile.reveal_tile
    tile.number

  end

  def won?
    # if there are no not-revealed tiles that are not bombs

    won = true
    @grid.each do |row|
      row.each do |tile|
        won = false if (!tile.revealed && !tile.bomb)
      end
    end

    return won
  end

  # private

    # def neighbor_tiles(coord_array)
    #   coord_array.map do |coords|
    #     @grid[coords]
    #   end
    # end

    def seed_grid
      @BOMBS.times do
        bomb_placed = false
        until bomb_placed
          pos = [rand(@Y_DIM), rand(@X_DIM)]
          unless self[pos].bomb
            self[pos].bomb = true
            bomb_placed = true
          end
        end
      end
    end

    # def get_neighbors(y, x)
    #   deltas = [-1, 0, 1].repeated_permutation(2).to_a
    #
    #   neighbors = []
    #   deltas.each do |delta|
    #     delta_y, delta_x = delta
    #     new_y = y + delta_y
    #     new_x = x + delta_x
    #     neighbors << [new_y, new_x] if valid_square?(new_y, new_x)
    #   end
    #
    #   neighbors
    # end

    def valid_square?(pos)
      y, x = pos
      y.between?(0, @Y_DIM-1) && x.between?(0, @X_DIM-1)
    end

end

class Minesweeper

  def initialize
    @board = Board.new
  end

  def play
    game_over = false
    start_time = Time.new
    until game_over
      user_input = get_user_input
      user_y, user_x = user_input[1]
      p user_input
      if user_input[0] == :flag
        @board.flag_tile(user_input[1])
      elsif user_input[0] == :reveal
        did_player_lose = @board[user_input[1]].reveal_tile
        game_over = :lost if did_player_lose == :lose
      end

      unless game_over
        game_over = :won if @board.won?
      end

      # TODO write test on Board to see if the game is over and if it's won or lost
    end
    end_time = Time.new

    puts "You #{game_over.to_s} in #{end_time - start_time} seconds"
    display_board_game_over
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
    elsif user_input[0] == 's'
      puts "Name your game"
      self.save(gets.chomp)
    elsif user_input[0] == 'l'
      puts "Which game would you like to load"
      self.load_game(gets.chomp)
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
      @board[user_coordinates].flag
    elsif user_action == :reveal
      @board[user_coordinates].reveal
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
            print "."
          else
            print "."
          end
        end
      end
      puts ""
    end
  end

  def display_board_game_over
    board_array = @board.grid #to-do refactor this later

    board_array.each do |row|
      row.each do |tile|
        if tile.bomb
          print "*"
        else
          print tile.number == 0 ? "_" : tile.number
        end
      end
      puts ""
    end

    nil
  end

  def save(name)
    yaml_game = @board.to_yaml
    File.open(name, "w") do |f|
      f.puts yaml_game
    end
  end

  def load_game(name)
    yaml_game = File.read(name)
    @board = YAML::load(yaml_game)
  end
end
