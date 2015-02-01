class Game < ActiveRecord::Base
  belongs_to :winner, class_name: "Player"
  belongs_to :turn, class_name: "Player"
  has_many :boards
  has_many :players, through: :boards 
end
