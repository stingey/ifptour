# app/controllers/concerns/dashboards_concern.rb

module TeamFormatterConcern
  extend ActiveSupport::Concern

  def format_teams(tournament)
    singles(tournament) if tournament.singles?
    double_draw_your_partner(tournament) if tournament.double_draw_your_partner?
    single_draw_your_partner(tournament) if tournament.single_draw_your_partner?
  end

  private

  def singles(tournament)
    raise TeamFormatterError.new(msg: 'Singles requires 2 or more participants') if
      tournament.participants.count < 2

    participants_array = participants_array_hash(tournament.participants)
    ChallongeApi.bulk_add_teams(tournament.challonge_id, participants_array)
  end

  def double_draw_your_partner(tournament)
    raise TeamFormatterError.new(msg: 'Double draw your partner requires 4 or more participants') if
      tournament.participants.count < 4
    raise TeamFormatterError.new(msg: 'Double draw your partner requires 16 or less participants') if
      tournament.participants.count > 16

    teams_array = make_both_sets(tournament.participants)
    formatted_teams = teams_array.map { |team_set| team_set.map { |team| team.join('/').titleize } }.flatten
    ordered_formatted_teams = order_teams(formatted_teams)
    participants_array = participants_array_hash(ordered_formatted_teams)
    ChallongeApi.bulk_add_teams(tournament.challonge_id, participants_array)
  end

  def single_draw_your_partner(tournament)
    raise TeamFormatterError.new(msg: 'Double draw your partner requires 4 or more participants') if
      tournament.participants.count < 4

    teams_array = make_teams(tournament.participants)
    formatted_teams = teams_array.map { |team| team.join('/').titleize }.flatten
    participants_array = participants_array_hash(formatted_teams)
    ChallongeApi.bulk_add_teams(tournament.challonge_id, participants_array)
  end

  def participants_array_hash(players)
    players.map do |player|
      { name: player }
    end
  end

  # if even number of teams
  def teams_even(array)
    team = []
    array.shuffle!
    array.each_slice(2){|t| team << t }
    team
  end

  # if odd number of teams
  def teams_odd(array)
    team = []
    array.shuffle!
    array.each_slice(2){|t| team << t }
    team.last << array[rand(0..array.length-2)]
    team
  end

  # find what player shows up twice
  def double(arr)
    frequency = Hash.new(0)
    arr.flatten.each { |x| frequency[x] += 1 }
    frequency.max_by { |x, y| y }[0]
  end

  # makes a team whether even or odd
  def make_teams(array)
    if array.length.even?
      teams_even(array)
    else
      teams_odd(array)
    end
  end

  # checks to see if any of the teams are the same
  def check_for_diff_teams(array1, array2)
    array1.each do |x|
      array2.each do |y|
        return false if x == y || x == y.reverse
      end
    end
    true
  end

  # makes 2 sets of different teams
  def make_both_sets(arr)
    teams1 = make_teams(arr)
    teams2 = make_teams(arr)
    teams2 = make_teams(arr) while check_for_diff_teams(teams1, teams2) == false || double(teams1) == double(teams2)
    [teams1, teams2]
  end

  def order_teams(teams_array)
    four_team_order =   [0, 2, 3, 1]
    six_team_order =    [0, 3, 4, 1, 2, 5]
    eight_team_order =  [0, 4, 6, 2, 3, 7, 5, 1]
    ten_team_order =    [0, 5, 8, 3, 4, 9, 6, 1, 2, 7]
    twelve_team_order = [0, 6, 9, 3, 4, 10, 7, 1, 2, 8, 11, 5]
    fourteen_team_order = [0, 7, 10, 3, 5, 12, 8, 1, 2, 9, 13, 6, 4, 11]
    sixteen_team_order = [0, 8, 12, 4, 6, 14, 10, 2, 3, 11, 15, 7, 5, 13, 9, 1]
    return four_team_order.map { |index| teams_array[index] } if teams_array.count == 4
    return six_team_order.map { |index| teams_array[index] } if teams_array.count == 6
    return eight_team_order.map { |index| teams_array[index] } if teams_array.count == 8
    return ten_team_order.map { |index| teams_array[index] } if teams_array.count == 10
    return twelve_team_order.map { |index| teams_array[index] } if teams_array.count == 12
    return fourteen_team_order.map { |index| teams_array[index] } if teams_array.count == 14
    return sixteen_team_order.map { |index| teams_array[index] } if teams_array.count == 16

    teams_array
  end
end
