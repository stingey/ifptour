class CreateRankingDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :ranking_details do |t|
      t.references :player, foreign_key: true
      t.integer :singles_points
      t.integer :doubles_points
      t.integer :womens_singles_points
      t.integer :womens_doubles_points
      t.string :singles_rank
      t.string :dobules_rank
      t.string :womens_singles_rank
      t.string :womens_doubles_rank

      t.timestamps
    end
  end
end
