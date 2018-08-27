class LocalTournament < ApplicationRecord
  belongs_to :club

  validates :name, presence: true
  validates :format, presence: true

  after_create :create_unique_url

  enum format: [:double_draw_your_partner, :single_draw_your_partner, :draw_your_partner_bring_your_partner, :single_bring_your_partner]

  def create_unique_url
    update(unique_url: "#{created_at.strftime("%Y%m%d")}#{rand.to_s[2..11]}")
  end
end
