class GamesController < ApplicationController
  rescue_from StandardError, with: :error
  # Drop cross site forgery protection, not necessary.
  skip_before_action :verify_authenticity_token
    
  # Public: Renders a paginated HTML list of all games.
  #
  # page - A String containing the listing page.
  def index
    # Games with nil state cannot be displayed.
    @games = Game.where.not(state: nil).paginate(page: params[:page])
  end

  # Public: Renders a HTML page showing the dynamic state of an
  # individual game.
  #
  # id - A String containing the game id.
  def show
    @game = Game.find(params[:id])
  end
  
  # Public: Renders a HTML page showing the game boards and player names
  # of an individual game.
  #
  # id - A String containing the game id.
  def playing
    @game = Game.find(params[:id])
    render partial: "playing_game", locals: { game: @game }
  end

  # Public: Returns the current game status.
  #
  # player - A String containing the player's name.
  # game_id - An Integer game id.
  #
  # Returns A JSON dictionary response containing the Integer game id, 
  # a String indicating the state of the game, and a Boolean indicating if 
  # it's the player's turn.  The state is "waiting" if a game has been started
  # but not yet joined, "playing" if the game is underway, and "finished" if
  # the game is done.
  def status
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.find(params[:game_id])
    
    id, state, my_turn = game.status(player)
    
    render json: { game_id: id, state: state, my_turn: my_turn }
    
  end

  # Public: Fires a shot at an opponent's board.
  #
  # player - A String containing the player's name.
  # shot   - A String representing the coordinates of a shot, e.g., "A-5".
  # game_id - An Integer game id.
  #
  # Returns A JSON dictionary response containing the Integer game id, a Boolean 
  # indicating if a ship was hit, and, if a ship was sunk, the Integer 
  # size of the ship.
  def fire
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.find(params[:game_id])
    
    # Game saves itself if it's successful.
    id, hit, sunk = game.fire(player, params[:shot])
    
    render json: { game_id: id, hit: hit, sunk: sunk }
  end

  # Public: Starts a game.  If an error occurs, destroys it.
  #
  # player - A String containing the player's id.
  #
  # Returns A JSON dictionary response containing the Integer game id.
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

  # Public: Add a player to an existing game.
  #
  # player - A String containing the player's id.
  # board - A board represented by a 2-D array, whose contents are ships.
  # game_id - An Integer game id.
  #
  # Returns A JSON dictionary response containing the Integer game id.
  def join
    player = Player.find_or_create_by!(name: params[:player])
    game = Game.find(params[:game_id])
    
    # Game saves itself if it's successful.
    id = game.join(player, params[:board])
    
    render json: { game_id: id } 
  end
  
  # Internal: Catches an renders any erros.
  #
  # Returns nothing.
  private
    def error(ex)
      #puts "Request Error: #{ex.message}"
      render status: :bad_request, json: { error: ex.message }
    end
end
