module ApplicationHelper
  def setup_player(player)
    player || RankingDetail.new
    player
  end
end
