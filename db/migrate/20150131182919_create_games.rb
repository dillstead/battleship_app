class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :state
      t.integer :turn_id
      t.integer :winner_id

      t.timestamps null: false
    end
  end
end
