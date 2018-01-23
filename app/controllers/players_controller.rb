class PlayersController < ApplicationController
  before_action :authenticate, only: [:new]

  def new
    @player = Player.new
  end

  def show
    @player = Player.find(params[:id])
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  private

  def authenticate
    redirect_to rankings_singles_path unless current_user.try(:admin)
  end

  def player_params
    params.require(:player).permit(:first_name, :last_name, :gender, :state,
                                   ranking_detail_attributes: [:id, :player_id, :singles_points, :doubles_points, :womens_singles_points, :womens_doubles_points])
  end
end
