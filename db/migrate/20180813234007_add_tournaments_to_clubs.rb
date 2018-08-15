class AddTournamentsToClubs < ActiveRecord::Migration[5.1]
  def change
    add_reference :local_tournaments, :club, foreign_key: true
  end
end
