# app/controllers/concerns/dashboards_concern.rb

module TeamFormatterConcern
  extend ActiveSupport::Concern

  def format_teams(tournament, challonge_id)
    double_draw_your_partner(tournament, challonge_id) if tournament.double_draw_your_partner?
  end

  private

  def double_draw_your_partner(tournament, challonge_id)
    teams_array = make_both_sets(tournament.participants)
    formatted_teams = teams_array.map { |team_set| team_set.map { |team| team.join("/").titleize } }.flatten
    ordered_formatted_teams = order_teams(formatted_teams)
    ordered_formatted_teams.each do |team|
      ChallongeApi.add_team(challonge_id, team)
    end

  end

  def teams_even(array) # if even number of teams
    team =[]
    array.shuffle!
    array.each_slice(2){|t| team << t }
    return team
  end

  def teams_odd(array) # if odd number of teams
    team = []
    array.shuffle!
    array.each_slice(2){|t| team << t }
    team.last << array[rand(0..array.length-2)]
    return team
  end

  def double(arr) # find what player shows up twice
    frequency = Hash.new(0)
    arr.flatten.each{|x| frequency[x] += 1 }
    return frequency.max_by{|x, y| y}[0]
  end

  def make_teams(array) # makes a team whether even or odd
    if array.length.even?
      teams_even(array)
    else
      teams_odd(array)
    end
  end

  def check_for_diff_teams(array1, array2) # checks to see if any of the teams are the same
    array1.each do |x|
      array2.each do |y|
        if x == y || x == y.reverse
          return false
        end
      end
    end
    return true
  end

  def make_both_sets(arr) # makes 2 sets of different teams
    teams1 = make_teams(arr)
    teams2 = make_teams(arr)
    while check_for_diff_teams(teams1, teams2) == false || double(teams1) == double(teams2)
      teams2 = make_teams(arr)
    end
    return teams1, teams2
  end

  def order_teams(teams_array)
    debugger
    six_team_order = [0, 3, 4, 1, 2, 5]
    eight_team_order = [0, 4, 6, 2, 3, 7, 5, 1]
    ten_team_order = [0, 5, 8, 3, 4, 9, 6, 1, 2, 7]
    return six_team_order.map{ |index| teams_array[index] } if teams_array.count == 6
    return eight_team_order.map{ |index| teams_array[index] } if teams_array.count == 8
    return ten_team_order.map{ |index| teams_array[index] } if teams_array.count == 10
    teams_array
  end

end
