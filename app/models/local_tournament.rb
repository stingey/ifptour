class LocalTournament < ApplicationRecord
  belongs_to :club

  validates :name, presence: true
  validates :format, presence: true

  after_create :create_unique_url

  ELIMINATIONS = [['single elimination', 'single_elimination'], ['double elimination', 'double_elimination']].freeze

  FORMATS = [['double draw your partner', 'double_draw_your_partner'],
             ['single draw your partner', 'single_draw_your_partner'],
             ['draw your partner, bring your partner', 'draw_youor_partner_bring_your_partner'],
             ['single bring your partner', 'single_bring_your_partner']].freeze

  enum format: %i[double_draw_your_partner single_draw_your_partner draw_your_partner_bring_your_partner single_bring_your_partner]

  def create_unique_url
    update(unique_url: "#{created_at.strftime('%Y%m%d')}#{rand.to_s[2..11]}")
  end
end
