class GamesController < ApplicationController
  rescue_from StandardError, with: :error
    
  def index
    # Games with nil state cannot be displayed.
    @games = Game.where.not(state: nil).paginate(page: params[:page])
  end

  def show
    @game = Game.find(params[:id])
  end

  def status
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.find(params[:game])
    
    id, state, my_turn = game.status(player)
    
    render json: { game_id: id, state: state, my_turn: my_turn }
    
  end

  def fire
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.find(params[:game])
    
    # Game saves itself if it's successful.
    id, hit, sunk = game.fire(player, params[:shot])
    
    render json: { game_id: id, hit: hit, sunk: sunk }
  end

  def start
    player = Player.find_or_create_by!(name: params[:player])
    # Game saves itself if it's successful.
    game = Game.create

    begin
      id = game.start(player, params[:board])
    rescue
      # Destroy the game if any type of error occurred.
      game.destroy
      raise
    end
    
    render json: { game_id: id } 
  end

  def join
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.find(params[:game])
    
    # Game saves itself if it's successful.
    id = game.join(player, params[:board])
    
    render json: { game_id: id } 
  end
  
  private
    def error(ex)
      #puts "Request Error: #{ex.message}"
      render status: :bad_request, json: { error: ex.message }
    end
end
