require 'rails_helper'
require "csv"

feature 'Collect Points' do
  scenario 'search names', js: true do

    # csv_text = File.read('spec/scraper/data_input/sample_player_list.csv')
    csv_text = File.read('spec/scraper/data_input/sample_player_list.csv')
    csv_name_file = CSV.parse(csv_text, :headers => false)

    visit 'http://ifp.everguide.com/commander/tour/public/PlayerProfile.aspx'
    CSV.open('spec/scraper/data_output/name_state_points.csv', 'wb') do |csv|
      csv << ['name', 'name/state', 'ranking']
      csv_name_file.each do |row|
        find('#R_Input').set(row.first)
        next unless page.has_css?('#R_c0')
        find('#R_c0').click()
        name_and_state = find('#lblName').text
        ranking = find('#lblRating').text
        csv << [row.first, name_and_state, ranking]
      end
    end
  end
end
