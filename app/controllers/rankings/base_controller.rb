# rankings controller
module Rankings
  # other thing
  class BaseController < ApplicationController
    protected

    def index
      players = instance_variable_get("@#{controller_name}")
      puts "\n\n#{players.first.inspect}\n\n\n"
      if params[:term]
        @players = players.where('first_name LIKE ? OR last_name LIKE ?', "%#{params[:term]}%", "%#{params[:term]}%").order(singles_points: :desc)
      else
        @players = singles? ? players.joins(:ranking_detail).order('ranking_details.singles_points desc') : players.joins(:ranking_detail).order('ranking_details.doubles_points desc')
      end
    end

    def show
    end

    private

    def singles?
      controller_name.include?('singles')
    end
  end
end
