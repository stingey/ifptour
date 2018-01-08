class CreateTournaments < ActiveRecord::Migration[5.1]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :contact
      t.string :location

      t.timestamps
    end
  end
end
