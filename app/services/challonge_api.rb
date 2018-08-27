class ChallongeApi
  include HTTParty

  def self.add_team(tournament_id, team)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/participants.json"
    query = { :api_key => ENV["CHALLONGE_KEY"], :name => team }
    HTTParty.post(url, query: { api_key: ENV["CHALLONGE_KEY"], participant: { name: team } })
  end

  def self.bulk_add_players(tournament_id, participants)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/participants/bulk_add.json"
    HTTParty.post(url, query: { api_key: ENV["CHALLONGE_KEY"], participants: participants })
  end

  def self.finalize(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/finalize.json"
    HTTParty.post(url, :query => { :api_key => ENV["CHALLONGE_KEY"] })
  end
end
