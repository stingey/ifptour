class TournamentsController < ApplicationController
  def index
    @tournaments = Tournament.all
  end

  def show
  end
end
