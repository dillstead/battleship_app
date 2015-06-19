class Location < ActiveRecord::Base
  belongs_to :board
  validates :ship , format: { with: /\A\z|\A[A-E]-[2-5]\z/, 
    message: "must be [A-E]-[2-5]" }
  validates :coordinate , format: { with: /\A\z|\A[A-J]-(10?|[2-9])\z/, 
    message: "must be [A-J]-[1-10]" }
  validates :x, numericality: { only_integer: true, greater_than_or_equal_to: 0,
    less_than: 10 }
  validates :y, numericality: { only_integer: true, greater_than_or_equal_to: 0,
    less_than: 10 }
  validates :board_id, presence: true
  
  # Public: Returns the location's state - "hit" if the location is hit
  # and it contains a ship, "miss" if the location is hit and it doesn't
  # contain a ship, and "open" otherwise.
  #
  # Returns a String containing the state.
  def state
    # Hit - if hit and has a ship
    return "hit" if self.hit && self.ship != ""
    # Miss - is hit and doesn't have a ship
    return "miss" if self.hit && self.ship == ""
    # Open - if not yet fired on
    "open"
  end
end
