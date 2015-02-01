class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.references :player, index: true

      t.timestamps null: false
    end
    add_foreign_key :boards, :players
  end
end
