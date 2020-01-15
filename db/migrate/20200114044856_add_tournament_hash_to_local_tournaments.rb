class AddTournamentHashToLocalTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :local_tournaments, :tournament_hash, :text
  end
end
