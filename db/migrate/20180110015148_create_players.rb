class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :singles_points
      t.integer :doubles_points
      t.integer :womens_singles_points
      t.integer :womens_doubles_points
      t.string :gender, null: false
      t.string :state

      t.timestamps
    end
  end
end
