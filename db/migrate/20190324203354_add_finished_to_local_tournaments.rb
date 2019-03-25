class AddFinishedToLocalTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :local_tournaments, :finished, :boolean, default: false
    add_column :local_tournaments, :started, :boolean, default: false
  end
end
