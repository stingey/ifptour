class AddStatusToLocalTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :local_tournaments, :status, :string, null: false, default: 'signing_up'
    remove_column :local_tournaments, :finished
    remove_column :local_tournaments, :started
  end
end
