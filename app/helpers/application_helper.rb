module ApplicationHelper
  def full_title(title = '')
    base_title = 'Pro Foosball Tour'
    if title.empty?
      base_title
    else
      "#{title} | #{base_title}"
    end
  end

  def errors_for(object, field)
    object.displayed_errors ||= []
    output = "<div class='invalid-feedback' id='#{object.class.to_s.underscore}_#{field}_invalid_message'><ul>"
    object&.errors&.full_messages_for(field)&.each do |error|
      output += "<li>#{error.humanize}</li>"
      object.displayed_errors |= [field]
    end
    output += '</ul></div>'
    output.html_safe
  end

  def round_name(number)
    if number.positive?
      "Round #{number}"
    else
      "Loser's round #{number.abs}"
    end
  end

  def format_address(club)
    if club.address2.present?
      club.address1 + ', ' + club.address2
    else
      club.address1
    end
  end

  def did_this_player_win?(player, tournament, round, match)
    return if player.blank?
    return if player == 'bye'
    return 'winner' if round_5_results(player, tournament, round, match)
    return 'winner' if round_6_results(player, tournament, round, match)
    winner_route = tournament.winner_mapping_engine(round.to_s, match.to_s)
    return if winner_route.blank?
    return unless tournament.tournament_hash.dig(winner_route.first, winner_route.second)[winner_route.last] == player

    'winner'
  end

  def round_5_results(player, tournament, round, match)
    return false unless round == :round_5
    if tournament.tournament_hash.dig(:round_6, :match_1).blank?
      tournament.results_hash[:first_place] == player
    else
      tournament.tournament_hash.dig(:round_5, :match_1)[1] == player
    end
  end

  def round_6_results(player, tournament, round, match)
    return false unless round == :round_6
    tournament.results_hash[:first_place] == player
  end
end
