class PlayerRankingService
  def perform
    singles_players.each.with_index(1) do |player, index|
      player.ranking_detail.update_attributes(singles_position: index)
    end
  end

  private

  def rank(players)
    players.each.with_index(1) do |player, index|
      player.ranking_detail.update_attributes(singles_position: index)
    end
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
    Player.female.joins(:ranking_detail).order('ranking_details.singles_points desc')
  end
end
