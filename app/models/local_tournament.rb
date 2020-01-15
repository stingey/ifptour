class LocalTournament < ApplicationRecord
  serialize :tournament_hash
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

  # after_update :fill_out_byes
  after_create :create_unique_url
  after_destroy :destroy_challonge_tournament

  ELIMINATIONS = [['single elimination', 'single_elimination'], ['double elimination', 'double_elimination']].freeze

  FORMATS = [%w[singles singles],
             ['double draw your partner', 'double_draw_your_partner'],
             ['single draw your partner', 'single_draw_your_partner'],
             ['draw your partner, bring your partner', 'draw_your_partner_bring_your_partner'],
             ['single bring your partner', 'single_bring_your_partner']].freeze

  def winners_rounds
    hash = tournament_hash.dup
    hash.each_key do |key|
      next unless key.to_s.split('_').any? { |element| element == 'losers' }

      hash.delete(key)
    end
    hash
  end

  def losers_rounds
    hash = tournament_hash.dup
    hash.each_key do |key|
      next unless key.to_s.split('_').none? { |element| element == 'losers' }

      hash.delete(key)
    end
    hash
  end

  def fill_out_byes
    tournament_hash.each do |round|
      round.last.each do |match|
        next unless match.last.any? { |player| player == 'bye' }

        match_to_advance_to = match_mapper(match)
        advancing_team = match.last.find{ |player| player != 'bye' } || 'bye'
        tournament_hash["round_#{round.first.to_s.split('_').last.to_i + 1}".to_sym]["match_#{match_to_advance_to}".to_sym] << advancing_team
      end
    end
    save
  end

  def match_mapper(match)
    if match.first.to_s.split('_').any? { |element| element == 'b' }
      return 'b_1' if [1, 2].include?(match.first.to_s.split('_').last.to_i)
      return 'b_2' if [3, 4].include?(match.first.to_s.split('_').last.to_i)
    else
      return '1' if [1, 2].include?(match.first.to_s.split('_').last.to_i)
      return '2' if [3, 4].include?(match.first.to_s.split('_').last.to_i)
    end
  end

  def map_the_win(round, match, winner)
    unless round.split('_').first == 'losers'
      losing_team = tournament_hash.dig(round.to_sym, match.to_sym).find { |team| team != winner }
      losing_routes = loser_mapping_engine(round, match)
      tournament_hash.dig(losing_routes.first, losing_routes.second)[losing_routes.last] = losing_team
    end
    winning_routes = winner_mapping_engine(round, match)
    tournament_hash.dig(winning_routes.first, winning_routes.second)[winning_routes.last] = winner
    save
  end

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
    return if participants.count < 2
    array = participants.dup
    last = array.pop
    return unless array.map(&:downcase).include?(last.downcase)

    errors.add(:base, 'Names must be unique.')
  end

  def available_frequent_participants
    club.frequent_participants.map(&:downcase) - participants.map(&:downcase)
  end

  # rubocop:disable Metrics/MethodLength
  def winner_mapping_engine(round, match)
    return [:round_2, :match_1, 0] if round == 'round_1' && match == 'match_1'
    return [:round_2, :match_1, 1] if round == 'round_1' && match == 'match_2'
    return [:round_2, :match_2, 0] if round == 'round_1' && match == 'match_3'
    return [:round_2, :match_2, 1] if round == 'round_1' && match == 'match_4'
    return [:round_2, :match_b_1, 0] if round == 'round_1' && match == 'match_b_1'
    return [:round_2, :match_b_1, 1] if round == 'round_1' && match == 'match_b_2'
    return [:round_2, :match_b_2, 0] if round == 'round_1' && match == 'match_b_3'
    return [:round_2, :match_b_2, 1] if round == 'round_1' && match == 'match_b_4'

    return [:round_3, :match_1, 0] if round == 'round_2' && match == 'match_1'
    return [:round_3, :match_1, 1] if round == 'round_2' && match == 'match_2'
    return [:round_3, :match_b_1, 0] if round == 'round_2' && match == 'match_b_1'
    return [:round_3, :match_b_1, 1] if round == 'round_2' && match == 'match_b_2'

    return [:round_4, :match_1, 0] if round == 'round_3' && match == 'match_1'
    return [:round_4, :match_1, 1] if round == 'round_3' && match == 'match_b_1'

    return [:round_5, :match_1, 0] if round == 'round_4' && match == 'match_1'

    return [:losers_round_2, :match_1, 0] if round == 'losers_round_1' && match == 'match_1'
    return [:losers_round_2, :match_2, 0] if round == 'losers_round_1' && match == 'match_2'
    return [:losers_round_2, :match_b_1, 0] if round == 'losers_round_1' && match == 'match_b_1'
    return [:losers_round_2, :match_b_2, 0] if round == 'losers_round_1' && match == 'match_b_2'
  end

  def loser_mapping_engine(round, match)
    return [:losers_round_1, :match_1, 0] if round == 'round_1' && match == 'match_1'
    return [:losers_round_1, :match_1, 1] if round == 'round_1' && match == 'match_2'
    return [:losers_round_1, :match_2, 0] if round == 'round_1' && match == 'match_3'
    return [:losers_round_1, :match_2, 1] if round == 'round_1' && match == 'match_4'
    return [:losers_round_1, :match_b_1, 0] if round == 'round_1' && match == 'match_b_1'
    return [:losers_round_1, :match_b_1, 1] if round == 'round_1' && match == 'match_b_2'
    return [:losers_round_1, :match_b_2, 0] if round == 'round_1' && match == 'match_b_3'
    return [:losers_round_1, :match_b_2, 1] if round == 'round_1' && match == 'match_b_4'

    return [:losers_round_2, :match_2, 1] if round == 'round_2' && match == 'match_1'
    return [:losers_round_2, :match_1, 1] if round == 'round_2' && match == 'match_2'
    return [:losers_round_2, :match_b_2, 1] if round == 'round_2' && match == 'match_b_1'
    return [:losers_round_2, :match_b_1, 1] if round == 'round_2' && match == 'match_b_2'
  end
  # rubocop:enable Metrics/MethodLength
end
