module ApplicationHelper
  def setup_player(player)
    player || RankingDetail.new
    player
  end

  def full_title(title = '')
    base_title = "IFP Tour"
    if title.empty?
      base_title
    else
      "#{title} | #{base_title}"
    end
  end

end
