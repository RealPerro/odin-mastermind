#MasterMind Game for Odin Project Course
require 'pry-byebug'#binding.pry
require 'colorize'

class MasterMindGame

  attr_accessor :game_state, :current_turn
  @@ref_colors = [:red, :green, :blue, :yellow, :white, :cyan]
  @@colors = ["r", "g", "b", "y", "w", "c"]

  @@modes = {
    1 => {:code_maker => "human", :code_breaker => "computer"},
    2 => {:code_maker => "human", :code_breaker => "human"},
    3 => {:code_maker => "computer", :code_breaker => "computer"},
    4 => {:code_maker => "computer", :code_breaker => "human"},
  }

  def initialize(n_turns = 12, game_mode = 4)
    @current_turn = n_turns
    @code_maker = @@modes[game_mode][:code_maker]
    @code_breaker = @@modes[game_mode][:code_breaker]
    @secret_code = get_secret_code()
    @game_state = 'started'
    @history = Array.new(n_turns) {Array.new(8)}
  end

  def get_secret_code
    if @code_maker == 'human'
      valid = false
      while valid == false
        puts "Please enter your 6-color code"
        puts color_print(@@colors)
        puts "are accepted."
        code = gets[0,6].split("")
        if code.all? {|c| @@colors.include?(c)}
          puts "Yep, it worked"
          valid = true
        else
          puts "Please enter valid colors"
          valid = false
        end
      end
      #color_print(code)
      return code
   else
      code = 6.times.map {@@colors.sample}
      #color_print(code)
      return code  
   end
  end

  def color_print(array)
    color_showcase = []
    array.each {|color| 
      color_showcase.push(@@colors.include?(color) ? color.colorize(@@ref_colors[@@colors.index(color)]) : color)}
      #binding.pry
      return color_showcase.join(" ")
  end

  def print_gameboard
    system('clear')
    puts "Code Maker = #{@code_maker}, code Breaker = #{@code_breaker}."
    puts "Game status = #{@game_state}."
    puts "code Breaker has #{@current_turn} tries left."
    puts ""
    puts "- c o d e -"

    if @game_state == 'started'
      puts "* * * * * *"
    else
      puts "#{color_print(@secret_code)}"
    end

    puts([*1..6, "exact", "in"].join(" "))
    @history.each {|line| puts color_print(line)}
  end

  def play_guess
    puts "type your guess"
    guess = gets[0,6].split("")
    feedback = get_feedback(guess)
    @history[@current_turn] = guess.push(feedback)
    @current_turn -= 1
    if feedback[0] == 6
      @game_state = "finished"
    end
  end

  def get_feedback(guess)
    exact = 0
    in_code = 0
    temp_code = @secret_code.dup
    guess.each_with_index do |char, idx|
      #count exact matches
      if char == temp_code[idx]
        exact += 1
        temp_code[idx] = "already used"
      end
    end
    guess.each_with_index do |char, idx|
      #count partial matches only after all exact matches have been accounted
      if temp_code.include?(char)
        in_code += 1
        temp_code[temp_code.index(char)] = "already used"
      end
    end
    return [exact, in_code]
  end
  
end

#gameflow
game = MasterMindGame.new(4,2)
game.print_gameboard
while game.game_state == "started"
  game.play_guess
  game.print_gameboard
  if game.current_turn == 0
    game.game_state = 'finished'
  end
end
game.print_gameboard
puts "game finished*********"