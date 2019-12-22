# Delayed::Job.enqueue(CreatePlayersWithPointsJob.new)
# class CreatePlayersWithPointsJob
  # def perform
  #   # Player.destroy_all
  #   csv_text_one = CSV.read('spec/scraper/data_output/name_state_points_one.csv', headers: false)
  #   csv_text_two = CSV.read('spec/scraper/data_output/name_state_points_two.csv', headers: false)
  #   csv_text_three = CSV.read('spec/scraper/data_output/name_state_points_three.csv', headers: false)
  #   csv_text_four = CSV.read('spec/scraper/data_output/name_state_points_four.csv', headers: false)
  #   csv_text_five = CSV.read('spec/scraper/data_output/name_state_points_five.csv', headers: false)
  #   csv_text_six = CSV.read('spec/scraper/data_output/name_state_points_six.csv', headers: false)
  #   csv_text_seven = CSV.read('spec/scraper/data_output/name_state_points_seven.csv', headers: false)
  #   csv_text_eight = CSV.read('spec/scraper/data_output/name_state_points_eight.csv', headers: false)
  #   csv_text_nine = CSV.read('spec/scraper/data_output/name_state_points_nine.csv', headers: false)
  #   csv_text_ten = CSV.read('spec/scraper/data_output/name_state_points_ten.csv', headers: false)

  #   # csv_name_file = csv_text_one + csv_text_two + csv_text_three + csv_text_four + csv_text_five +
  #   #                 csv_text_six
  #   csv_name_file = csv_text_one + csv_text_two + csv_text_three + csv_text_four + csv_text_five +
  #                   csv_text_six + csv_text_seven + csv_text_eight + csv_text_nine + csv_text_ten

  #   csv_name_file.each do |row|
  #     name = row[0].split
  #     unless name.all? { |part| row[1].downcase.include?(part.downcase) }
  #       puts "\n#{name}"
  #       next
  #     end

  #     state = if row[1].split.pop.match(/\(([^()]+)\)/).present?
  #               row[1].split.pop.match(/\(([^()]+)\)/)[1]
  #             else
  #               ''
  #             end
  #     points = row[2]
  #     mens_points = points.scan(/[0-9]{3,4}*\/[0-9]{3,4}/)[0]&.split('/')
  #     womens_points = points.scan(/[0-9]{3,4}*\/[0-9]{3,4}/)[1]&.split('/')
  #     first_name = name.shift
  #     last_name = name.join(' ')
  #     gender = points.downcase.include?('women') ? 'F' : 'M'
  #     next if gender.blank? || last_name.blank? || first_name.blank?

  #     player = Player.find_by(first_name: first_name, last_name: last_name, state: state)
  #     player = Player.create(first_name: first_name, last_name: last_name, gender: gender, state: state) unless player.present?
  #     if player.ranking_detail.present?
  #       player.ranking_detail.update_columns(singles_points: mens_points&.first,
  #                                            doubles_points: mens_points&.last,
  #                                            womens_singles_points: womens_points&.first,
  #                                            womens_doubles_points: womens_points&.last)
  #     else
  #       player.build_ranking_detail(singles_points: mens_points&.first || 0,
  #                                   doubles_points: mens_points&.last || 0,
  #                                   womens_singles_points: womens_points&.first || 0,
  #                                   womens_doubles_points: womens_points&.last || 0)
  #     end
  #     player.save!
  #   end
  # end
# end
