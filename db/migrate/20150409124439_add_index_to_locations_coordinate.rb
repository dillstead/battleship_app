class AddIndexToLocationsCoordinate < ActiveRecord::Migration
  def change
    add_index :locations, :coordinate
  end
end
