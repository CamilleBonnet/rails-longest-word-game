require 'open-uri'
require 'json'

URL = "https://wagon-dictionary.herokuapp.com/"

class GameController < ApplicationController
  def begin
    @grid_size = params[:grid_size].to_i
    # @grid = generate_grid(@grid_size)
    session[:grid] = generate_grid(@grid_size)
    # @start_time = Time.now
    session[:start_time] = Time.now
  end

  def score
    # @start_time = Time.parse(params[:user_start])
    @user_attempt = params[:word_found]
    # @grid = params[:grid].split(",")
    @end_time = Time.now
    # @user_stat = run_game(@user_attempt, @grid, @start_time, @end_time)
    @user_stat = run_game(@user_attempt, session[:grid], Time.parse(session[:start_time]), @end_time)
  end



  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    result = JSON.parse(open(URL + attempt).read)

    user_perf = {}
    # p result["word"]
    time = time_spent(start_time, end_time)
    # if word is found
    if result["found"]
      attempt_good(result, grid, time, user_perf)
    else
      attempt_wrong(result, user_perf, time)
    end
    user_perf
  end

  def attempt_good(result, grid, time, user)
    # check if the attempt is ok with the grid
    msg = "Your message is not in the grid"
    return attempt_wrong(result, user, time, msg) unless check_attempt?(result["word"], grid)

    # compute the score
    compute_score(result, time, user)
  end

  def check_attempt?(result, grid)
    good_attempt = true
    result.upcase.split(//).each do |letter|
      ind = grid.find_index(letter)
      ind ? grid.delete_at(ind) : good_attempt = false
    end
    return good_attempt
  end

  def compute_score(result, time, user)
    user[:message] = "WELL DONE !!"
    user[:score] = (result["length"] * 30 / time).round(2)
    user[:time] = time
  end

  def time_spent(start_t, end_t)
    (end_t - start_t).round(1)
  end

  def attempt_wrong(result, user, time_spent, message = "")
    message = message == '' ? "#{result['error']} silly fool! This is not an english word !" : message
    user[:message] =  message
    user[:score] = 0
    user[:time] = time_spent
  end


  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    (1..grid_size).each do
      grid.push((0...1).map { (65 + rand(26)).chr }.join)
    end
    grid
  end
end
