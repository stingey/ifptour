require 'HTTParty'
require 'byebug'
require 'Nokogiri'
require 'net/http'
require 'csv'

class PlayerNameScraper

  POSTBODY_URLS = ['http://www.ifptour.com/tournaments/2018/2018_Hall_Of_Fame_Classic_p1.htm',
          'http://www.ifptour.com/tournaments/2018/2018_Hall_Of_Fame_Classic_p2.htm',
          'http://ifptour.com/tournaments/2016/2016_Hall_Of_Fame_Classic_p1.htm',
          'http://ifptour.com/tournaments/2016/2016_Hall_Of_Fame_Classic_p2.htm',
          'http://www.ifptour.com/tournaments/2018/2018_FL_State.htm',
          'http://www.ifptour.com/tournaments/2018/2018_WI_State.htm',
          'http://www.ifptour.com/tournaments/2018/2018_IL_State.htm',
          'http://ifptour.com/tournaments/2018/2018_NY_State_Junior_Championships.htm',
          'http://ifptour.com/tournaments/2018/2018_TX_State_p1.htm',
          'http://ifptour.com/tournaments/2018/2018_TX_State_p2.htm',
          'http://www.ifptour.com/tournaments/2018/2018_MD_State.htm',
          'http://www.ifptour.com/tournaments/2018/2018_LA_State.htm',
          'http://www.ifptour.com/tournaments/2017/2017_LA_State.htm',
          'http://www.ifptour.com/tournaments/2016/2016_CO_State_p1.htm',
          'http://www.ifptour.com/tournaments/2016/2016_TN_State.htm',
          'http://ifptour.com/tournaments/2016/2016_TN_State_Warmup.htm',
          'http://ifptour.com/tournaments/2016/2016_NE_State.htm',
          'http://ifptour.com/tournaments/2016/2016_Worlds_p1.htm',
          'http://ifptour.com/tournaments/2016/2016_Worlds_p2.htm',
          'http://ifptour.com/tournaments/2016/2016_LA_State.htm',
          'http://www.ifptour.com/tournaments/2016/2016_Nationals_p1.htm',
          'http://www.ifptour.com/tournaments/2016/2016_Nationals_p2.htm',
          'http://www.ifptour.com/tournaments/2016/2016_OK_State.htm',
          'http://www.ifptour.com/tournaments/2016/2016_NY_State.htm',
          'http://ifptour.com/tournaments/2016/2016_TX_State.htm',
          'http://ifptour.com/tournaments/2016/2016_MD_State.htm',
          'http://www.ifptour.com/tournaments/2016/2016_IL_State.htm',
          'http://ifptour.com/tournaments/2016/2016_NY_State_Junior_Championships.htm',
          'http://ifptour.com/tournaments/2016/2016_Hall_Of_Fame_Classic_p1.htm',
          'http://ifptour.com/tournaments/2016/2016_Hall_Of_Fame_Classic_p2.htm',
          'http://www.ifptour.com/tournaments/2016/2016_FL_State.htm',
          'http://ifptour.com/tournaments/2016/2016_KY_State_p1.htm',
          'http://ifptour.com/tournaments/2016/2016_KY_State_p2.htm'
          ]

  EXCLUDE = %w[$ singles american mixed doubles hotel vegas tornado results classic ifp
               continued fame "kid" dyp estates _________________ forward examples goalie foosball wisconsin
               tampa harrisville maryland york texas illinois kick-off city "city," "heights," amsterdam kentucky usa]

  def get_player_names
    full_players_unfiltered = []
    POSTBODY_URLS.each do |url|
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
      if player.include?('&')
        two_player_name_array = player.split('&')
        players_filtered << format_player_name(two_player_name_array.first)
        second_name_array = two_player_name_array.last.split(' ')
        second_name_array.pop
        second_name_array.pop
        second_name_array.unshift(second_name_array.pop)
        players_filtered << second_name_array.join(' ')
      else
        players_filtered << format_player_name(player)
      end
    end
    players_filtered.map(&:downcase).uniq
  end

  def format_player_name(name)
    name_into_array = name.split(' ')
    name_into_array.shift
    name_into_array.pop
    name_into_array.pop
    name_into_array.unshift(name_into_array.pop)
    name_into_array.join(' ')
  end

  def write_to_file
    names = format_player_names
    CSV.open('spec/scraper/data_input/player_master_list.csv', 'wb') do |csv|
      names.each do |name|
        csv << [name]
      end
    end
  end
end

PlayerNameScraper.new.write_to_file
