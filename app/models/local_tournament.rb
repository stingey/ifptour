class LocalTournament < ApplicationRecord
  enum format: %i[singles double_draw_your_partner single_draw_your_partner draw_your_partner_bring_your_partner single_bring_your_partner]

  enum status: {
    signing_up: 'signing_up',
    started: 'started',
    finished: 'finished'
  }

  belongs_to :club

  validates :name, presence: true
  validates :format, presence: true
  validate :participants_count_is_ok
  validate :participants_names_are_unique

  after_create :create_unique_url
  after_destroy :destroy_challonge_tournament

  ELIMINATIONS = [['single elimination', 'single_elimination'], ['double elimination', 'double_elimination']].freeze

  FORMATS = [%w[singles singles],
             ['double draw your partner', 'double_draw_your_partner'],
             ['single draw your partner', 'single_draw_your_partner'],
             ['draw your partner, bring your partner', 'draw_your_partner_bring_your_partner'],
             ['single bring your partner', 'single_bring_your_partner']].freeze

  def create_unique_url
    update(unique_url: "#{created_at.strftime('%Y%m%d')}#{rand.to_s[2..11]}")
  end

  def destroy_challonge_tournament
    return if challonge_id.blank?

    ChallongeApi.delete_tournament(challonge_id)
  end

  def participants_count_is_ok
    return unless double_draw_your_partner?
    return if participants.count <= 16
    return if participants.count > 3

    errors.add(:base, 'Double draw your partner requires 16 or less participants') if participants.count <= 16
    errors.add(:base, 'Double draw your partsner requires 4 or more participants') if participants.count > 3
  end

  def participants_names_are_unique
    return if participants.map(&:downcase).count == participants.map(&:downcase).uniq.count

    errors.add(:base, 'Names must be unique')
  end

  def available_frequent_participants
    club.frequent_participants.map(&:downcase) - participants.map(&:downcase)
  end
end
