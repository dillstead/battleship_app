class GamesController < ApplicationController
  rescue_from StandardError with :error
    
  def index
  end

  def show
  end

  def status
  end

  def fire
  end

  def start
    # TODO validate parameters
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.new
    
    game.start player, params[:board]
    game.save!
    
    render json: { game_id: game.id } 
  end

  def join
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.find(params[:game])
    
    game.join! player, params[:board]
    game.save!
    
    render json: { game_id: game.id } 
  end
  
  private
    def error(ex)
      render status: :bad_request, json: { error: ex.message }
    end
end
