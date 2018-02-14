class AddPositionToRankingDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :ranking_details, :singles_position, :integer
    add_column :ranking_details, :doubles_position, :integer
    add_column :ranking_details, :womens_singles_position, :integer
    add_column :ranking_details, :womens_doubles_position, :integer
  end
end
