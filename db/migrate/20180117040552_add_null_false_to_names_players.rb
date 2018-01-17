class AddNullFalseToNamesPlayers < ActiveRecord::Migration[5.1]
  def up
    change_column :players, :first_name, :string, null: false
    change_column :players, :last_name, :string, null: false
    change_column :ranking_details, :singles_points, :integer, null: false
    change_column :ranking_details, :doubles_points, :integer, null: false
  end

  def down
    change_column :players, :first_name, :string
    change_column :players, :last_name, :string
    change_column :ranking_details, :singles_points, :integer
    change_column :ranking_details, :doubles_points, :integer
  end
end
