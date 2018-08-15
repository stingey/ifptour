class AddParticipantsToTournament < ActiveRecord::Migration[5.1]
  def change
    add_column :local_tournaments, :participants, :text, array: true, default: []
  end
end
