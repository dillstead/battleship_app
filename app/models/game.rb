class Game < ActiveRecord::Base
  belongs_to :winner, class_name: "Player"
  belongs_to :turn, class_name: "Player"
  has_many :boards, dependent: :destroy
  has_many :players, through: :boards 
  validates :state, inclusion: { in: ["waiting", "playing", "finished", nil],
    message: "%{value} is not a valid state" }
  
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
