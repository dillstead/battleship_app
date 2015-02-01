class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :board, index: true
      t.string :ship
      t.integer :x
      t.integer :y
      t.boolean :hit
      t.string :coordinate

      t.timestamps null: false
    end
    add_foreign_key :locations, :boards
  end
end
