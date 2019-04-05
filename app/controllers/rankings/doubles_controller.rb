module Rankings
  class DoublesController < ApplicationController
    def index
      players = Player.all
      if params[:term].present?
        @search = true
        players_result = players.where("first_name || ' ' || last_name ILIKE ?", "%#{params[:term]}%")
                                .joins(:ranking_detail)
                                .order('ranking_details.doubles_points desc')
      else
        players_result = players.joins(:ranking_detail)
                                .order('ranking_details.doubles_points desc')
      end
      if params[:rank_class].present?
        players_result = players_result.joins(:ranking_detail).where('ranking_details.doubles_rank = ?', params[:rank_class])
      end
      @players = players_result.page params[:page]
    end
  end
end
