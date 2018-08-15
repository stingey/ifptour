class CreateLocalTournaments < ActiveRecord::Migration[5.1]
  def change
    create_table :local_tournaments do |t|
      t.string :name
      t.timestamps
    end
  end
end
