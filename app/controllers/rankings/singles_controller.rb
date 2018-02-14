module Rankings
  class SinglesController < ApplicationController
    def index
      players = Player.all
      if params[:term]
        @players = players.where('first_name LIKE ? OR last_name LIKE ?', "%#{params[:term]}%", "%#{params[:term]}%")
                          .joins(:ranking_detail)
                          .order('ranking_details.singles_points desc')
      else
        @players = players.joins(:ranking_detail).order('ranking_details.singles_points desc')
      end
    end
  end
end
