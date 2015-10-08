require 'json'
@game_save_file = "crap.json"

def index_of(char)
  @basic_array[char]
end

def create_word_array
  @basic_array = Hash.new
  words_array.each_with_index{ |val, index|
    @basic_array[val] ||= []
    @basic_array[val] << index
  }
end

def new_game_setup
  generate_random_word

  @scrambled = "_" * length_of_word
  @lives = 5
  @words_to_guess = nil

  create_word_array
end

def begin_game
  puts "How would you like to start? (n) or new for new game, (l) or load for load game"

  begin
    puts "You entered an unsupported input\n" if @input_type == :unsupported
    input = gets.chomp.downcase
  end until(supported_actions(input))


  send(basic_allowed_actions[input])
  puts "Have fun guessing what I have in mind: #{@scrambled}.\nAfter #{@lives} wrong guesses you have lost the game."
end

def supported_actions(input)
  return true if basic_allowed_actions.keys.include? input
  @input_type = :unsupported
  false
end

def play_game
  begin_game
  until game_won || @lives == 0
    puts "You currently have #{@scrambled}"
    word = gets.chomp

    if in_game_actions.keys.include?(word)
      call_in_game_actions(word)
      break
    end

    analyze_input(word)
  end
end

def call_in_game_actions(input)
  send in_game_actions[input]
end

def basic_allowed_actions
  {
    "n" => :new_game_setup,
    "new" => :new_game_setup,
    "l" => :setup_loaded_game,
    "load" => :setup_loaded_game
  }
end

def in_game_actions
{
  "*" => :quit_game
}
end

def quit_game
  puts "So you want to quit?\nTo save your game enter (s) or save or any other keys to completely quit"
  input = gets.chomp

  send(save_game_or_quit[input]) if save_game_or_quit.keys.include? input
end

def save_game_or_quit
  {
    "s" => :save_game,
    "save" => :save_game
  }
end

def analyze_input(char)
  if @words_to_guess.include? char
    correct_input(char)
  else
    invalid_input
  end
end

def words_array
  @game_word.split('')
end

def chars_left
  @words_to_guess ||= words_array.uniq
  @words_to_guess
end


def invalid_input
  decrement_count

  puts "You guessed wrongly and have #{@lives} guesses left"
  puts "Sorry, you lost, the word was #{@game_word}" if @lives <= 0

  @status= :wrong
end

def correct_input(char)
  @words_to_guess.delete(char)

  puts "You guessed correctly keep guessing" unless game_won
  puts "Congratulations. You have won" if game_won

  index_of(char).each{ |i|
    @scrambled[i] = char
  }

  @status= :correct
end


def decrement_count
  @lives -= 1
end

def game_won
  if chars_left.length == 0
    @game_has_been_won = :won
    true
  end
end

def to_h
  {lives: @lives, words_to_guess: @words_to_guess, basic_array: @basic_array, game_word: @game_word, scrambled: @scrambled}
end

def save_game
  File.open(@game_save_file, 'a+') do |f|
    f.puts to_h.to_json
  end

  puts my_game_id
end

def my_game_id
  "Your game ID is: #{File.readlines(@game_save_file).size - 1}.\n To continue your saved game, enter this id when prompted for a game record"
end

def generate_random_word
  begin
    pick_random_word_from_dictionary
  end until(word_is_valid?)
end

def pick_random_word_from_dictionary
  upper_limit = File.readlines('5desk.txt').size
  @game_word = File.readlines('5desk.txt')[rand(upper_limit)].chomp.downcase
end

def length_of_word
  @game_word.length
end

def word_is_valid?
  true if length_of_word >= 4 && length_of_word < 10
end

def setup_loaded_game
  id = request_game_id

  load_game load_game_data(id.to_i)
end

def request_game_id
  print "Please enter your game ID: "
  id = gets.chomp
end

def load_game_data(data_line)
  File.readlines('crap.json')[data_line.to_i]
end

def load_game(json_data)
  x = JSON.parse(json_data)
  @lives = x["lives"]
  @words_to_guess = x["words_to_guess"]
  @basic_array = x["basic_array"]
  @game_word = x["game_word"]
  @scrambled = x["scrambled"]
end
