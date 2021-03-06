class Game < ActiveRecord::Base
  belongs_to :winner, class_name: "Player"
  belongs_to :turn, class_name: "Player"
  # The board created first is the first board.
  has_many :boards, -> { order "created_at ASC" }, dependent: :destroy
  # The first player created the first board.
  has_many :players, -> { order "boards.created_at ASC" }, through: :boards 
  validates :state, inclusion: { in: ["waiting", "playing", "finished", nil],
    message: "%{value} is not a valid state" }
  
  # Public: Returns the first player's board.  The first player is the player
  # that started the game.
  #
  # Returns a Board or nil if there is no board.
  def first_player_board
    self.boards[0]
  end
  
  # Public: Returns the second player's board.  The second player is the player
  # that joined the game.
  #
  # Returns a Board or nil if there is no board.
  def second_player_board
    self.boards[1]
  end
  
  # Public: Returns the first player's name.  The first player is the player that
  # started the game.
  #
  # Returns a name String or nil if there is no first player.
  def first_player_name
    self.players[0].nil? ? nil : self.players[0].name
  end
  
  # Public: Returns the second player's name.  The second player is the player 
  # that joined the game.
  #
  # Returns a name String or nil if there is no second player.
  def second_player_name
    self.players[1].nil? ? nil : self.players[1].name
  end
  
  # Public: Creates a new board and saves it to the database.  If any exceptions 
  # are thrown the database is cleaned up before returning.
  #
  # player   - The Player that wants to start the game.
  # rawBoard - A board represented by a 2-D array, whose contents are ships.
  #
  # Returns the Integer game id.
  def start(player, rawBoard)
    raise ArgumentError, "Incorrect state #{self.state}" unless self.state.nil?
    my_board = boards.create!(player_id: player.id)
    begin
      my_board.add_locations rawBoard
      # The player that starts the game gets to go first.
      self.turn_id = player.id
      # Now wait for the opponent to join.
      self.state = "waiting"
      save!
    rescue
      # Undo any database changes that were made before returning.
      boards.destroy my_board
      # A call to raise by itself will raise the last error.
      raise    
    end
    return self.id
  end 

  # Public: Add a player to an existing game and updates the database.  If any 
  # exceptions are thrown the database is cleaned up before returning.
  #
  # player   - The Player that wants to join the game.
  # rawBoard - A board represented by a 2-D array, whose contents are ships.
  #
  # Returns The Integer game id.
  # Raises ArgumentError if the game is not in the correct state.
  # Raises ArgumentError if the player started the game.
  def join(player, rawBoard)
    raise ArgumentError, "Incorrect state #{self.state}" unless self.state == "waiting"
    # The joining player cannot already be playing the game.
    raise ArgumentError, "Player cannot join game he/she started" if player.id == self.turn_id
    my_board = boards.create!(player_id: player.id)
    begin 
      my_board.add_locations rawBoard
      # The game is officially underway!
      self.state = "playing"
      save!
    rescue
      # Only destroy the board that was just added, not the one added at the
      # start of the game.
      boards.destroy my_board
      # A call to raise by itself will raise the last error.
      raise    
    end 
    return self.id
  end
  
  # Public: Fires a shot at an opponent's board and updates the database.
  #
  # player - The Player taking the shot.
  # shot   - A String representing the coorindates of a shot, e.g., "A-5".
  #
  # Returns the Integer game id, a Boolean indicating if a ship was hit,
  # and, if a ship was sunk, the Integer size of the ship.
  # Raises ArgumentError if the game is not in the correct state.
  # Raises ArgumentError if the player is not part of the game.
  # Raises ArgumentError if it's not the player's turn.
  def fire(player, shot)
    # The game better be underway and it better be my turn.
    raise ArgumentError, "Incorrect state #{self.state}" unless self.state == "playing"
    raise ArgumentError, "Not part of the game" if players.find_by(id: player.id).nil?
    raise ArgumentError, "Not your turn" unless player.id == self.turn_id
    # Find the opponents board and take the shot.
    their_board = boards.where.not(player: player).take
    raise ArgumentError, "Cannot find board" if their_board.nil?
    hit, sunk, won = their_board.fire shot
    # Update the state based on the shot - hit (and sunk (and won)) or miss.
    if won
      self.state = "finished"
      self.winner = player
    else
      other_player = players.where.not(id: player.id).take
      self.turn = other_player
    end
    save!
    return self.id, hit, sunk
  end
  
  # Public: Returns the current game status.
  #
  # player - The Player requesting the status.
  #
  # Returns the Integer game id, a String indicating if the player has 
  # won or lost the game, and a Boolean indicating if it's the player's turn.
  # Raises ArgumentError if the player is not part of the game.
  # Raises ArgumentError if the game hasn't been started.
  def status(player)
    raise ArgumentError, "Not part of the game" if players.find_by(id: player.id).nil?
    raise ArgumentError, "Game hasn't started" if self.state.nil?
    my_turn = player.id == self.turn_id
    state = self.state
    if self.state == "finished"
      if player.id == self.winner_id
        state = "won"
      else
        state = "lost"
      end
    end
    return self.id, state, my_turn
  end
  
end
