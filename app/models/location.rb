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

end
