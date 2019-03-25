class ChallongeApi
  include HTTParty

  API_KEY = ENV['CHALLONGE_KEY']

  def self.add_team(tournament_id, team)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/participants.json"
    query = { api_key: API_KEY, participant: { name: team } }
    json_response = HTTParty.post(url, query: query)
    check_for_errors(json_response)
    json_response
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

  def self.check_for_errors(json_response)
    return unless json_response.parsed_response.is_a?(Array) && json_response.parsed_response.dig('errors')&.any?

    raise ChallongeApiError.new(errors: json_response.parsed_response['errors'])
  end
end
