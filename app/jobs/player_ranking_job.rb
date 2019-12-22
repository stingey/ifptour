class PlayerRankingJob
  COLUMNS = {
    singles: :singles_position=,
    doubles: :doubles_position=,
    womens_singles: :womens_singles_position=,
    womens_doubles: :womens_doubles_position=
  }.freeze

  # def perform
  #   rank(singles_players, COLUMNS[:singles])
  #   rank(doubles_players, COLUMNS[:doubles])
  #   rank(womens_singles_players, COLUMNS[:womens_singles])
  #   rank(womens_doubles_players, COLUMNS[:womens_doubles])
  # end

  private

  def rank(players, position)
    # players.each.with_index(1) do |player, index|
    #   player.ranking_detail.send("previous_#{position}".to_sym, player.ranking_detail.send(position.to_s.chop.to_sym))
    #   player.ranking_detail.send(position, index)
    #   player.ranking_detail.save
    # end
  end

  def singles_players
    Player.joins(:ranking_detail).order('ranking_details.singles_points desc')
  end

  def doubles_players
    Player.joins(:ranking_detail).order('ranking_details.doubles_points desc')
  end

  def womens_singles_players
    Player.female.joins(:ranking_detail).order('ranking_details.womens_singles_points desc')
  end

  def womens_doubles_players
    Player.female.joins(:ranking_detail).order('ranking_details.womens_doubles_points desc')
  end
end
