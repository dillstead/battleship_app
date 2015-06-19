class Board < ActiveRecord::Base
  belongs_to :player
  belongs_to :game
  # Order the locations row by row.
  has_many :locations, -> { order "x ASC", "y ASC" }, dependent: :destroy
  validates :player_id, presence: true
  validates :game_id, presence: true
  # Board size is 10 x 10.
  BOARD_SIZE = 100
  
  # Public: Adds locations and saves them to the database.  If exceptions
  # are thrown the database is cleaned up before returning.
  #
  # rawLocations - Locations represented by a 2-D array, whose contents are 
  # ships.
  #
  # Returns Nothing.
  # Raises ArgumentError if location validation failed.
  # Raises ArgumentError if the number of locations is incorrect.
  def add_locations(rawLocations)
      numLocations = 0
      rawLocations.each_with_index do |row, x|
        row.each_with_index do |col, y|
          location = locations.build(ship: rawLocations[x][y], x: x, y: y, hit: false, 
            coordinate: "#{("A".ord + x).chr}-#{y + 1}")
          raise ArgumentError, 
            "Validation failed: #{location.errors.full_messages.join(", ")}" unless location.valid?
          numLocations += 1
        end
      end
      raise ArgumentError, "Incorrect number of locations" unless numLocations == BOARD_SIZE
      # Save the objects in one fell swoop after they have all been validated.
      # This is less likely to have to "unwind" the database.
      begin
        save!
      rescue
        # Undo any database changes that were made before returning.
        locations.clear
        # A call to raise by itself will raise the last error.
        raise
      end
  end
  
  # Public: Fires a shot at a location.
  #
  # shot - A String representing the coorindates of a shot, e.g., "A-5".
  #
  # Returns a Boolean indicating if a ship was hit, if a ship was sunk, 
  # the Integer size of the ship, and a Boolean indicating if the game
  # was just won.
  # Raises ArgumentError if the shot could not be located.
  def fire(shot)
    # Lookup the location
    location = locations.find_by(coordinate: shot)
    raise ArgumentError, "Cannot locate shot" if location.nil?
    sunk, won = 0, false
    location.hit = true
    location.save!
    unless location.ship == ""
      # Check to see if the ship was sunk before declaring victory.
      if locations.where(ship: location.ship, hit: false).count == 0
        # Grab the size of the ship that was just sunk.
        sunk = location.ship.split("-")[1]
        # Victory is declared if there are no more locations with ships
        # that haven't been hit.
        won = true if locations.where("ship != '' and hit == 'f'").count == 0
      end
    end
    return location.state == "hit", sunk.to_i, won
  end
end
