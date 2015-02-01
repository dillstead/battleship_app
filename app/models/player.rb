class Player < ActiveRecord::Base
  has_many :boards
  has_many :games, through: :boards
end