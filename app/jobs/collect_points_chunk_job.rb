require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'
require 'csv'

# Configurations
class CollectPointsChunkJob
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

  def initialize(array, file_name)
    @array_of_names = array
    @file_name = file_name
  end

  def perform
    browser = Capybara.current_session
    browser.visit 'http://ifp.everguide.com/commander/tour/public/PlayerProfile.aspx'
    CSV.open("spec/scraper/data_output/name_state_points_#{@file_name}.csv", 'wb') do |csv|
      @array_of_names.each do |row|
        browser.find('#R_Input').set(row.first)
        next unless browser.has_css?('#R_c0')

        browser.find('#R_c0').click
        sleep 2
        name_and_state = browser.find('#lblName').text
        ranking = browser.find('#lblRating').text
        csv << [row.first, name_and_state, ranking]
      rescue Capybara::ElementNotFound
        next
      end
    end
  end
end
