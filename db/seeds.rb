# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
tournaments = [
  ['$25K Kentucky State/Tour Kickoff', Date.new(2018, 1, 25), Date.new(2018, 1, 28), 'Mary Moore', 'Lexington, KY'],
  ['$7.5 Florida State', Date.new(2018, 2, 9), Date.new(2018, 2, 11), 'Rob Kadle', 'Tampa, FL'],
  ['$60K Hall Of Fame Classic', Date.new(2018, 3, 28), Date.new(2018, 4, 1), 'Mary Moore', 'Las Vegas, NV'],
  ['$25K Kentucky State/Tour Kickoff', Date.new(2017, 1, 26), Date.new(2017, 1, 29), 'Mary Moore', 'Lexington, KY'],
  ['NRW Foosball Clubs Series', Date.new(2017, 2, 4), Date.new(2017, 2, 4), 'John O\'Brien', 'Oswego, NY'],
]

tournaments.each do |name, start_date, end_date, contact, location|
  Tournament.create(name: name, start_date: start_date, end_date: end_date, contact: contact, location: location)
end



150.times do
  rando = 600 + rand(4700)
  player = Player.create(first_name: FFaker::Name.first_name_male, last_name: FFaker::Name.last_name, gender: 'M')
  RankingDetail.create(player_id: player.id, singles_points: rando, doubles_points: rando - rand(500))
end

40.times do
  rando = 600 + rand(3500)
  player = Player.create(first_name: FFaker::Name.first_name_female,
                         last_name: FFaker::Name.last_name,
                         gender: 'F')
  RankingDetail.create(player_id: player.id, 
                       singles_points: rando,
                       doubles_points: rando - rand(500),
                       womens_singles_points: rando + rand(1000),
                       womens_doubles_points: rando + rand(600))
end

