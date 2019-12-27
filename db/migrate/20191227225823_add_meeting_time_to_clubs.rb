class AddMeetingTimeToClubs < ActiveRecord::Migration[5.1]
  def change
    add_column :clubs, :meeting_time, :string
  end
end
