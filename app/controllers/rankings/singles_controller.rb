module Rankings
  class SinglesController < ApplicationController
    def index
      players = Player.all
      if params[:term].present?
        @search = true
        players_result = players.where("first_name || ' ' || last_name ILIKE ?", "%#{params[:term]}%")
                                .joins(:ranking_detail)
                                .order('ranking_details.singles_points desc')
      else
        players_result = players.joins(:ranking_detail)
                                .order('ranking_details.singles_points desc')
      end
      if params[:rank_class].present?
        players_result = players_result.joins(:ranking_detail).where('ranking_details.singles_rank = ?', params[:rank_class])
      end
      @players = players_hash(players_result)
    end

    private

    def players_hash(players)
      players.each_with_object([]) do |player, array|
        array << {
          id: player.id,
          position: player.ranking_detail.singles_position,
          player_name: player.full_name,
          rank: player.ranking_detail.singles_rank,
          gender: player.gender,
          points: player.ranking_detail.singles_points
        }
      end
    end
  end
end
