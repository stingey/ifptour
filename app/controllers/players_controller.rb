class PlayersController < ApplicationController
  before_action :authenticate, only: [:new, :create]

  def new
    @player = Player.new
    @player.build_ranking_detail
  end

  def edit
    @player = Player.find(params[:id])
  end

  def show
    @player = Player.find(params[:id])
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to rankings_singles_path
    else
      render 'new'
    end
  end

  def update
    @player = Player.find(params[:id])
    if @player.update(player_params)
      redirect_to rankings_singles_path
    else
      render 'edit'
    end
  end

  private

  def player_params
    params.require(:player).permit(:first_name, :last_name, :gender, :state,
                                   ranking_detail_attributes: [:id, :player_id, :singles_points, :doubles_points, :womens_singles_points, :womens_doubles_points])
  end
end
