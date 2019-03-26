require 'HTTParty'
require 'byebug'
require 'Nokogiri'
require 'net/http'
require 'csv'

class PlayerNameScraper
   URLS = ['http://www.ifptour.com/tournaments/2018/2018_Hall_Of_Fame_Classic_p1.htm',
          'http://www.ifptour.com/tournaments/2018/2018_Hall_Of_Fame_Classic_p2.htm',
          'http://ifptour.com/tournaments/2016/2016_Hall_Of_Fame_Classic_p1.htm',
          'http://ifptour.com/tournaments/2016/2016_Hall_Of_Fame_Classic_p2.htm',
          'http://www.ifptour.com/tournaments/2018/2018_FL_State.htm',
          'http://www.ifptour.com/tournaments/2018/2018_WI_State.htm',
          'http://www.ifptour.com/tournaments/2018/2018_IL_State.htm',
          'http://ifptour.com/tournaments/2018/2018_NY_State_Junior_Championships.htm',
          'http://ifptour.com/tournaments/2018/2018_TX_State_p1.htm',
          'http://www.ifptour.com/tournaments/2018/2018_MD_State.htm'
          ]

  EXCLUDE = %w[& singles mixed doubles hotel vegas tornado results classic ifp
               continued fame "kid" dyp estates _________________ forward examples goalie foosball wisconsin
               tampa harrisville maryland york texas illinois]

  def get_player_names
    full_players_unfiltered = []
    URLS.each do |url|
      doc = HTTParty.get(url)
      parse_page = Nokogiri::HTML(doc)
      parse_page.css('.postbody1')&.each do |player|
        next if player.children.count > 1
        next if player.text.empty?
        next if EXCLUDE.any? { |word| player.children.text.downcase.include?(word) }
        next if player.text == " "
        full_players_unfiltered << player.text
      end
    end
    full_players_unfiltered
  end

  def format_player_names
    players = get_player_names
    players_filtered = []
    players.each do |player|
      name_into_array = player.split(' ')
      name_into_array.shift
      name_into_array.pop
      name_into_array.pop
      players_filtered << name_into_array.join(' ')
    end
    players_filtered.map(&:downcase).uniq
  end

  def put_first_name_first
    player_names = format_player_names
    ordered_names = player_names.map do |player_name|
      name_array = player_name.split(' ')
      first_name = name_array.pop
      name_array.unshift(first_name)
      name_array.join(' ')
    end
    ordered_names
  end

  def write_to_file
    names = put_first_name_first
    CSV.open('spec/scraper/data_input/player_master_list.csv', 'wb') do |csv|
      names.each do |name|
        csv << [name]
      end
    end
  end
end

PlayerNameScraper.new.write_to_file
