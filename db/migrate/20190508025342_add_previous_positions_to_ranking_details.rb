class AddPreviousPositionsToRankingDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :ranking_details, :previous_singles_position, :integer
    add_column :ranking_details, :previous_doubles_position, :integer
    add_column :ranking_details, :previous_womens_singles_position, :integer
    add_column :ranking_details, :previous_womens_doubles_position, :integer
  end
end
