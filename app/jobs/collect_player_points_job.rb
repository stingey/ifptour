# require 'selenium-webdriver'
# require 'nokogiri'
# require 'capybara'
# require 'csv'
# Configurations
# class CollectPlayerPointsJob
  # def perform
  #   csv_text = File.read('spec/scraper/data_input/full_player_master_list.csv')
  #   csv_name_file = CSV.parse(csv_text, headers: false)

  #   first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth =
  #     csv_name_file.each_slice((csv_name_file.size/10.0).round).to_a
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(first, 'one'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(second, 'two'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(third, 'three'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(fourth, 'four'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(fifth, 'five'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(sixth, 'six'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(seventh, 'seven'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(eighth, 'eight'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(ninth, 'nine'))
  #   Delayed::Job.enqueue(CollectPointsChunkJob.new(tenth, 'ten'))
  # end
# end
