class AddTournamentResultsToLocalTournament < ActiveRecord::Migration[5.1]
  def change
    add_column :local_tournaments, :results_hash, :jsonb, default: {}
  end
end
