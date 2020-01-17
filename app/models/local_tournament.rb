# rubocop:disable Metrics/ClassLength
class LocalTournament < ApplicationRecord
  serialize :tournament_hash
  serialize :results_hash
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

  # rubocop:disable Metrics/MethodLength
  def fill_out_byes
    tournament_hash.each do |round|
      round.last.each do |match|
        next unless match.last.include?('bye')
        if match.last.all? { |teams| teams == 'bye' } && match.last.count == 2
          map_the_win(round.first.to_s, match.first.to_s, 'bye')
          map_the_loss(round.first.to_s, match.first.to_s, 'bye')
        elsif match.last.count == 2 && match.last.count { |e| e == 'bye' } == 1 && match.last.none?(&:blank?)
          winner = match.last.find { |team| team != 'bye' }
          next if winner.blank?
          map_the_win(round.first.to_s, match.first.to_s, winner)
          map_the_loss(round.first.to_s, match.first.to_s, winner)
        end
        save
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def shrink_bracket
    tournament_hash.each do |round|
      tournament_hash.delete(round.first) if round.last.values.all? { |match| match.include?('bye') }
    end
    save
  end

  def map_the_win(round, match, winner, check_for_byes: false)
    winning_routes = winner_mapping_engine(round, match)
    tournament_hash.dig(winning_routes.first, winning_routes.second)[winning_routes.last] = winner
    advance_past_byes(winning_routes.first, winning_routes.second, winner) if check_for_byes
    save
  end

  def advance_past_byes(round, match, winner)
    return unless the_opponent_is_a_bye(round, match)

    map_the_win(round.to_s, match.to_s, winner, check_for_byes: true)
  end

  def the_opponent_is_a_bye(round, match)
    tournament_hash.dig(round, match).count == 2 &&
      tournament_hash.dig(round, match).count { |e| e == 'bye' } == 1
  end

  def map_the_loss(round, match, winner, check_for_byes: false)
    losing_team = tournament_hash.dig(round.to_sym, match.to_sym).find { |team| team != winner }
    return third_place_finish(losing_team) if round == 'losers_round_6'
    return if round.split('_').first == 'losers'

    losing_team = 'bye' if both_slots_are_byes(round, match)
    losing_routes = loser_mapping_engine(round, match, losing_team)
    if tournament_hash.dig(losing_routes.first, losing_routes.second).nil?
      advance_to_next_slot(losing_routes.first, losing_routes.second, losing_team)
    else
      tournament_hash.dig(losing_routes.first, losing_routes.second)[losing_routes.last] = losing_team
      advance_past_byes(losing_routes.first, losing_routes.second, losing_team) if check_for_byes
    end
    save
  end

  def third_place_finish(losing_team)
    results_hash[:third_place] = losing_team
    save
  end

  def advance_to_next_slot(round, match, winner)
    next_loser_routes = winner_mapping_engine(round.to_s, match.to_s)
    if tournament_hash.dig(next_loser_routes.first, next_loser_routes.second).nil?
      next_next_routes = winner_mapping_engine(next_loser_routes.first.to_s, next_loser_routes.second.to_s)
      tournament_hash.dig(next_next_routes.first, next_next_routes.second)[next_next_routes.last] = winner
    else
      tournament_hash.dig(next_loser_routes.first, next_loser_routes.second)[next_loser_routes.last] = winner
    end
    save
  end

  def create_unique_url
    update(unique_url: "#{created_at.strftime('%Y%m%d')}#{rand.to_s[2..11]}")
  end

  def destroy_challonge_tournament
    return if challonge_id.blank?

    ChallongeApi.delete_tournament(challonge_id)
  end

  def both_slots_are_byes(round, match)
    tournament_hash.dig(round.to_sym, match.to_sym).all? { |team| team == 'bye' } &&
      tournament_hash.dig(round.to_sym, match.to_sym).count == 2
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

  def setup_final(round, match, winner)
    if tournament_hash.dig(round.to_sym, match.to_sym).index(winner) == 1
      tournament_hash.dig(:round_6, :match_1)[0] = tournament_hash.dig(round.to_sym, match.to_sym)[0]
      tournament_hash.dig(:round_6, :match_1)[1] = tournament_hash.dig(round.to_sym, match.to_sym)[1]
    else
      results_hash[:first_place] = tournament_hash.dig(round.to_sym, match.to_sym)[0]
      results_hash[:second_place] = tournament_hash.dig(round.to_sym, match.to_sym)[1]
      update(status: 'finished')
    end
    save
  end

  def record_results(round, match, winner)
    loser = tournament_hash.dig(round.to_sym, match.to_sym).find { |player| player != winner }
    results_hash[:first_place] = winner
    results_hash[:second_place] = loser
    update(status: 'finished')
    save
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

    return [:losers_round_3, :match_1, 0] if round == 'losers_round_2' && match == 'match_1'
    return [:losers_round_3, :match_1, 1] if round == 'losers_round_2' && match == 'match_2'
    return [:losers_round_3, :match_b_1, 0] if round == 'losers_round_2' && match == 'match_b_1'
    return [:losers_round_3, :match_b_1, 1] if round == 'losers_round_2' && match == 'match_b_2'

    return [:losers_round_4, :match_1, 0] if round == 'losers_round_3' && match == 'match_1'
    return [:losers_round_4, :match_b_1, 0] if round == 'losers_round_3' && match == 'match_b_1'

    return [:losers_round_5, :match_1, 0] if round == 'losers_round_4' && match == 'match_1'
    return [:losers_round_5, :match_1, 1] if round == 'losers_round_4' && match == 'match_b_1'

    return [:losers_round_6, :match_1, 0] if round == 'losers_round_5' && match == 'match_1'

    return [:round_5, :match_1, 1] if round == 'losers_round_6' && match == 'match_1'
    # finalize_results
  end

  def loser_mapping_engine(round, match, losing_team)
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

    return [:losers_round_4, :match_1, 1] if round == 'round_3' && match == 'match_1'
    return [:losers_round_4, :match_b_1, 1] if round == 'round_3' && match == 'match_b_1'

    return [:losers_round_6, :match_1, 1] if round == 'round_4' && match == 'match_1'
  end
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/ClassLength
