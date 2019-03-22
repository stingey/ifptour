require 'HTTParty'
require 'byebug'
require 'Nokogiri'
require 'net/http'

class PlayerNameScraper

  URLS = ['http://www.ifptour.com/tournaments/2018/2018_Hall_Of_Fame_Classic_p1.htm',
          'http://www.ifptour.com/tournaments/2018/2018_Hall_Of_Fame_Classic_p2.htm']

  EXCLUDE = %w[& SINGLES MIXED DOUBLES Hotel Vegas Tornado Results Classic IFP continued FAME "Kid"]

  MANUAL_NAMES = ['TOMMY ADKISSON', 'BOBBY DIAZ', 'STEVEN SIMONS']

  def get_player_names
    full_players = []
    URLS.each do |url|
      doc = HTTParty.get(url)
      parse_page = Nokogiri::HTML(doc)
      players = parse_page.css('.postbody1').map do |player|
        next if EXCLUDE.any? { |word| player.children.text.include?(word) }
        player_without_place = player.children.text.scan(/[^ ]* (.*)/).flatten.first
        name_array = player_without_place&.split(' ')
        2.times { name_array&.pop }
        name_array&.unshift(name_array&.pop)
        first_name_first_name_array = name_array&.join(' ')
      end.compact
    full_players << players
    end
    full_players << MANUAL_NAMES
    final_player_list = full_players.flatten.uniq.compact.reject(&:empty?)
    hash = {keywords: final_player_list }
    hash
  end

  def start_point_scraper
    hash = get_player_names
    hash[:keywords] = hash[:keywords].first(150)
    puts hash
    params = {
      api_key: "tYdHK07eiTMu",
      start_url: "http://ifp.everguide.com/commander/tour/public/PlayerProfile.aspx",
      start_template: "main_template",
      start_value_override: hash.to_json,
      send_email: "1"
    }

    url = URI.parse('https://www.parsehub.com/api/v2/projects/tuZ-EOVOWTsH/run')
    url.query = URI.encode_www_form(params)

    puts Net::HTTP.post_form(url, params)
  end
end

PlayerNameScraper.new.start_point_scraper
