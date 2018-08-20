require 'httparty'

class ChallongeApi
  include HTTParty

  def self.finalize(tournament_id)
    url = "https://api.challonge.com/v1/tournaments/#{tournament_id}/finalize.json"
    HTTParty.post(url, :query => { :api_key => ENV["CHALLONGE_KEY"] })
  end
end
