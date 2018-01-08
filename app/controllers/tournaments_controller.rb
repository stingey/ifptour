class TournamentsController < ApplicationController
  def index
    @tournaments = Tournament.all.group_by { |tournament| tournament.start_date.year }
  end

  def show
  end
end
