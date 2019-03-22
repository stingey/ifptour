desc 'Updates the players with their points!'
require 'csv'

task load_players_and_points: :environment do

  csv_text = CSV.read('spec/scraper/data_output/name_state_points.csv', headers: true)

  csv_text.each do |row|
    name = row[0].split
    state = if row[1].split.pop.match(/\(([^()]+)\)/).present?
              row[1].split.pop.match(/\(([^()]+)\)/)[1]
            else
              ''
            end
    points = row[2]
    mens_points = points.scan(/[0-9]{3,4}*\/[0-9]{3,4}/)[0]&.split('/')
    womens_points = points.scan(/[0-9]{3,4}*\/[0-9]{3,4}/)[1]&.split('/')
    first_name = name.shift
    last_name = name.join(' ')
    gender = points.downcase.include?("women") ? 'F' : 'M'
    player = Player.create_with(first_name: first_name, last_name: last_name, gender: gender, state: state)
                   .find_or_create_by(first_name: first_name, last_name: last_name, gender: gender)
    if player.ranking_detail.present?
      player.ranking_detail.update_columns(singles_points: mens_points&.first,
                                          doubles_points: mens_points&.last,
                                          womens_singles_points: womens_points&.first,
                                          womens_doubles_points: womens_points&.last)
    else
      player.build_ranking_detail(singles_points: mens_points&.first,
                                  doubles_points: mens_points&.last,
                                  womens_singles_points: womens_points&.first,
                                  womens_doubles_points: womens_points&.last)
    end
    player.save!
  end
end
