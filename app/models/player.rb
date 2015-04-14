class Player < ActiveRecord::Base
  has_many :boards
  has_many :games, through: :boards
  validates :name, presence: true, uniqueness: true, length: { in: 3..25 }, 
    format: { with: /\w+/ }
  
end
