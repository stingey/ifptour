# app/controllers/concerns/dashboards_concern.rb

module TeamFormatterConcern
  extend ActiveSupport::Concern

  def format_teams(tournament)
    double_draw_your_partner(tournament) if tournament.double_draw_your_partner?
  end

  private

  def double_draw_your_partner(tournament)
    raise TeamFormatterError.new(msg: 'Double draw your partner requires 4 or more participants') if
      tournament.participants.count < 4

    teams_array = make_both_sets(tournament.participants)
    formatted_teams = teams_array.map { |team_set| team_set.map { |team| team.join('/').titleize } }.flatten
    ordered_formatted_teams = order_teams(formatted_teams)
    ordered_formatted_teams.each do |team|
      ChallongeApi.add_team(tournament.challonge_id, team)
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
    debugger
    team = []
    array.shuffle!
    array.each_slice(2){|t| team << t }
    team.last << array[rand(0..array.length-2)]
    team
  end

  # find what player shows up twice
  def double(arr)
    frequency = Hash.new(0)
    arr.flatten.each{|x| frequency[x] += 1 }
    frequency.max_by{ |x, y| y }[0]
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
    while check_for_diff_teams(teams1, teams2) == false || double(teams1) == double(teams2)
      teams2 = make_teams(arr)
    end
    [teams1, teams2]
  end

  def order_teams(teams_array)
    six_team_order = [0, 3, 4, 1, 2, 5]
    eight_team_order = [0, 4, 6, 2, 3, 7, 5, 1]
    ten_team_order = [0, 5, 8, 3, 4, 9, 6, 1, 2, 7]
    return six_team_order.map{ |index| teams_array[index] } if teams_array.count == 6
    return eight_team_order.map{ |index| teams_array[index] } if teams_array.count == 8
    return ten_team_order.map{ |index| teams_array[index] } if teams_array.count == 10

    teams_array
  end
end
