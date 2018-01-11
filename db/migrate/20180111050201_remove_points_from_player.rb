class RemovePointsFromPlayer < ActiveRecord::Migration[5.1]
  def change
    remove_column :players, :singles_points
    remove_column :players, :doubles_points
    remove_column :players, :womens_singles_points
    remove_column :players, :womens_doubles_points
  end
end
