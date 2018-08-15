class CreateClubs < ActiveRecord::Migration[5.1]
  def change
    create_table :clubs do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :address1
      t.string :address2
      t.timestamps
    end
  end
end
