class CreateLocalTournaments < ActiveRecord::Migration[5.1]
  def change
    create_table :local_tournaments do |t|
      t.string :name
      t.text :participants, array: true, default: []
      t.string :tournament_type, default: 'double elimination'
      t.string :unique_url
      t.string :challonge_url
      t.string :challonge_id
      t.timestamps
    end
  end
end
