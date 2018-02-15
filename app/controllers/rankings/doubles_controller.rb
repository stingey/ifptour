module Rankings
  class DoublesController < ApplicationController
    def index
      players = Player.all
      if params[:term]
        players_result = players.where('first_name LIKE ? OR last_name LIKE ?', "%#{params[:term]}%", "%#{params[:term]}%")
                          .joins(:ranking_detail)
                          .order('ranking_details.doubles_points desc')
      else
        players_result = players.joins(:ranking_detail)
                          .order('ranking_details.doubles_points desc')
      end
      @players = players_hash(players_result)
    end

    private

    def players_hash(players)
      players.each_with_object([]) do |player, array|
        array << {
          id: player.id,
          position: player.ranking_detail.doubles_position,
          player_name: player.full_name,
          rank: player.ranking_detail.doubles_rank,
          gender: player.gender,
          points: player.ranking_detail.doubles_points
        }
      end
    end
  end
end
