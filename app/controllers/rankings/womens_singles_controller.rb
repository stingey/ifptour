module Rankings
  class WomensSinglesController < BaseController
    def index
      players = Player.where(gender: 'F')
      if params[:term]
        @players = players.where('first_name LIKE ? OR last_name LIKE ?', "%#{params[:term]}%", "%#{params[:term]}%")
                          .joins(:ranking_detail)
                          .order('ranking_details.womens_singles_points desc')
      else
        @players = players.joins(:ranking_detail)
                          .order('ranking_details.womens_singles_points desc')
      end
    end
  end
end
