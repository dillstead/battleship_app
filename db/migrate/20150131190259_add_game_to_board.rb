class AddGameToBoard < ActiveRecord::Migration
  def change
    add_reference :boards, :game, index: true
    add_foreign_key :boards, :games
  end
end
