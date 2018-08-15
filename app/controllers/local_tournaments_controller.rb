class LocalTournamentsController < ApplicationController
  def index
    @tournaments = LocalTournament.all
  end

  def new
    @club = Club.find(params[:club_id])
    @club.local_tournaments.build
  end

  def show
    @tournament = LocalTournament.find(params[:id])
  end

  def create
    club = Club.find(params[:club_id])
    tournament = club.local_tournaments.build(local_tournaments_params)
    if tournament.save
      redirect_to club_local_tournament_path(tournament.club_id, tournament.id)
    else
      render 'new'
    end
  end

  private

  def local_tournaments_params
    params.require(:local_tournament).permit(:name)
  end
end
