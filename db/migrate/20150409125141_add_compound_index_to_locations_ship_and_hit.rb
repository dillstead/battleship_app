class AddCompoundIndexToLocationsShipAndHit < ActiveRecord::Migration
  def change
    add_index :locations, [:ship, :hit]
  end
end
