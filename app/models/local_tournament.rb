class LocalTournament < ApplicationRecord
  belongs_to :club

  after_create :create_unique_url

  def create_unique_url
    update(unique_url: "#{created_at.strftime("%Y%m%d")}#{rand.to_s[2..11]}")
  end
end
