require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'
# Configurations
class CollectPlayerPointsJob
  # Capybara.register_driver :selenium do |app|
  #   Capybara::Selenium::Driver.new(app, browser: :chrome)
  # end
  Capybara.register_driver(:headless_chrome) do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w[headless disable-gpu] }
    )

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      desired_capabilities: capabilities
    )
  end
  Capybara.javascript_driver = :chrome
  Capybara.configure do |config|
    config.default_max_wait_time = 10 # seconds
    config.default_driver = :headless_chrome
  end

  def perform
    time_start = Time.now
    browser = Capybara.current_session
    csv_text = File.read('spec/scraper/data_input/full_player_master_list.csv')
    csv_name_file = CSV.parse(csv_text, headers: false)

    browser.visit 'http://ifp.everguide.com/commander/tour/public/PlayerProfile.aspx'
    CSV.open('spec/scraper/data_output/name_state_points.csv', 'wb') do |csv|
      csv << ['name', 'name/state', 'ranking']
      csv_name_file.each do |row|
        browser.find('#R_Input').set(row.first)
        next unless browser.has_css?('#R_c0')

        browser.find('#R_c0').click()
        name_and_state = browser.find('#lblName').text
        ranking = browser.find('#lblRating').text
        csv << [row.first, name_and_state, ranking]
      end
    end
    time_end = Time.now
    puts "\n\n\n*************************"
    puts "\n_________________________"
    puts "\nfinished running in #{time_end - time_start}"
    puts 'player points have been loaded'
    puts "_________________________\n\n\n"
    Delayed::Job.enqueue(CreatePlayersWithPointsJob.new)
  end
end
