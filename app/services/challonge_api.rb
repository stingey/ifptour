class ChallongeApi
  include HTTParty

  API_KEY = ENV['CHALLONGE_KEY']

  def self.update_match(tournament_id, match_id, winner_id, scores_csv)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/matches/#{match_id}.json"
    query = { api_key: API_KEY, match: { winner_id: winner_id, scores_csv: scores_csv } }
    json_response = HTTParty.put(url, query: query)
    check_for_errors(json_response)
    json_response
  end

  def self.find_participant(tournament_id, participant_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/participants/#{participant_id}.json"
    query = { api_key: API_KEY }
    response = HTTParty.get(url, query: query)
    response&.parsed_response&.dig('participant')
  end

  def self.find_tournament(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}.json"
    query = { api_key: API_KEY }
    response = HTTParty.get(url, query: query)
    response&.parsed_response&.dig('tournament')
  end

  def self.find_matches(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/matches.json"
    query = { api_key: API_KEY }
    HTTParty.get(url, query: query)
  end

  def self.create_tournament(tournament)
    url = "https://api.challonge.com/v1/tournaments.json"
    query = { api_key: API_KEY, tournament: { name: tournament.name,
                                              url: tournament.unique_url,
                                              quick_advance: true,
                                              show_rounds: true} }
    query[:tournament][:tournament_type] = 'double elimination' if
      tournament.tournament_type == 'double_elimination'
    HTTParty.post(url, query: query)
  end

  def self.add_team(tournament_id, team)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/participants.json"
    query = { api_key: API_KEY, participant: { name: team } }
    json_response = HTTParty.post(url, query: query)
    check_for_errors(json_response)
    json_response
  end

  def self.bulk_add_teams(tournament_id, participants_array)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/participants/bulk_add.json"
    query = { api_key: API_KEY, participants: participants_array }
    HTTParty.post(url, query: query)
  end

  def self.update_tournament(tournament)
    url = "https://api.challonge.com/v1/tournaments/#{tournament.challonge_id}.json"
    query = { api_key: API_KEY, tournament: { name: tournament.name,
                                              tournament_type: tournament.tournament_type,
                                              url: tournament.unique_url,
                                              quick_advance: true,
                                              show_rounds: true}}
    json_response = HTTParty.put(url, query: query)
    check_for_errors(json_response)
    json_response
  end

  def self.clear_out_participants(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/participants/clear.json"
    query = { api_key: API_KEY }
    json_response = HTTParty.delete(url, query: query)
    json_response
  end

  def self.start(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/start.json"
    query = { api_key: API_KEY }
    json_response = HTTParty.post(url, query: query)
    check_for_errors(json_response)
    json_response
  end

  def self.finalize(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/finalize.json"
    query = { api_key: API_KEY }
    json_response = HTTParty.post(url, query: query)
    check_for_errors(json_response)
    json_response
  end

  def self.delete_tournament(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}.json"
    query = { api_key: API_KEY }
    HTTParty.delete(url, query: query)
  end

  def self.check_for_errors(json_response)
    return unless json_response.parsed_response.is_a?(Hash) && json_response.parsed_response.dig('errors')&.any?

    raise ChallongeApiError.new(errors: json_response.parsed_response['errors'])
  end
end
