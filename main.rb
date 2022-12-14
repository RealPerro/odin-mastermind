# MasterMind Game for Odin Project Course
require 'pry-byebug' # binding.pry
require 'colorize'

class MasterMindGame
  attr_accessor :game_state, :current_turn

  @@ref_colors = %i[red green blue yellow white cyan]
  @@colors = %w[r g b y w c]

  @@modes = {
    1 => {:code_maker => "human", :code_breaker => "computer"},
    2 => {:code_maker => "human", :code_breaker => "human"},
    3 => {:code_maker => "computer", :code_breaker => "computer"},
    4 => {:code_maker => "computer", :code_breaker => "human"},
  }

  def initialize(n_turns = 12, game_mode = 4, size = 4)
    @current_turn = n_turns
    @code_maker = @@modes[game_mode][:code_maker]
    @code_breaker = @@modes[game_mode][:code_breaker]
    @game_state = 'started'
    @history = Array.new(n_turns) {Array.new(8)}
    @size = size
    @all_possible_codes = @@colors.repeated_permutation(@size)
    @secret_code = get_secret_code()
    @temp_code = []
    @current_possible_codes = @all_possible_codes.dup
  end

  def get_secret_code
    if @code_maker == 'human'
      valid = false
      while valid == false
        puts "Please enter your #{@size}-color code"
        puts color_print(@@colors)
        puts 'are accepted.'
        code = gets[0,@size].split('')
        if code.all? { |c| @@colors.include?(c) }
          puts 'Yep, it worked'
          valid = true
        else
          puts 'Please enter valid colors'
          valid = false
        end
      end
    else
      code = 4.times.map { @@colors.sample }
    end
    code
  end

  def color_print(array)
    color_showcase = []
    array.each { |color|
      color_showcase.push(@@colors.include?(color) ? color.colorize(@@ref_colors[@@colors.index(color)]) : color) }
    color_showcase.join(" ")
  end

  def print_gameboard
    system('clear')
    puts "Code Maker = #{@code_maker}, code Breaker = #{@code_breaker}."
    puts "Game status = #{@game_state}."
    puts "Code Breaker has #{@current_turn} tries left."
    puts "Available colors: #{color_print(@@colors)}."
    puts '--------'
    puts "c o d e"

    if @game_state == 'started'
      puts '* ' * @size
    else
      puts "#{color_print(@secret_code)}"
    end
    puts '--------'
    puts([*1..@size, 'exact', 'in'].join(' '))
    puts "--------"
    @history.each { |line| puts color_print(line) }
    puts '--------'
  end

  def play_guess
    if @code_breaker == 'human' 
      puts "type your guess"
      guess = gets[0, @size].split("")
    elsif @code_breaker == 'computer'
      gets
      guess = get_computer_guess[0, @size]
    end
    feedback = get_feedback(guess)
    @history[@current_turn] = guess.push(feedback)
    @current_turn -= 1
    @game_state = 'finished' if (feedback[0] == @size)
  end

  def get_feedback(guess, code = @secret_code)
    exact = 0
    in_code = 0
    @temp_code = code.dup
    temp_guess = guess.dup

    temp_guess.each_with_index do |char, idx|
      # count exact matches
      if char == @temp_code[idx]
        exact += 1
        temp_guess[idx] = "used"
        @temp_code[idx] = "exact"
      end
    end

    temp_guess.each do |char|
      # count all matches
      if @temp_code.include?(char)
        in_code += 1
      end
    end
    [exact, in_code]
  end
  
  def get_computer_guess
    if @current_turn == 12
      first = @@colors.sample
      second = @@colors.sample
      guess = [first, first, second, second]
      return guess
    end
    previous_guess = @history[@current_turn + 1][0,@size]
    previous_feedback = @history[@current_turn + 1][@size]
    current_possible_codes(previous_guess, previous_feedback).sample
  end

  def current_possible_codes(guess, feedback)
    @current_possible_codes = @current_possible_codes.select {|code| get_feedback(guess, code) == feedback}
  end
end

# gameflow
puts 'Welcome to Ruby Mastermind'
puts 'Please choose game mode:'
puts '1 {:code_maker => "human", :code_breaker => "computer"},
2 {:code_maker => "human", :code_breaker => "human"},
3 {:code_maker => "computer", :code_breaker => "computer"},
4 {:code_maker => "computer", :code_breaker => "human"},'
mode_selection = gets.to_i
game = MasterMindGame.new(12, mode_selection, 4)
game.print_gameboard
while game.game_state == "started"
  game.play_guess
  game.print_gameboard
  if game.current_turn == 0
    game.game_state = 'finished'
  end
end
game.print_gameboard
puts 'game finished*********'
