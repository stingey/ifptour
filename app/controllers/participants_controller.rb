class ParticipantsController < ApplicationController
  def create
    @tournament = LocalTournament.find(params[:local_tournament_id])
    @tournament.participants << params[:players][:name]
    if @tournament.save
      redirect_to edit_club_local_tournament_path(@tournament.club, @tournament)
    else
      @tournament.participants.pop
      render 'local_tournaments/edit'
    end
  end

  def destroy
    @tournament = LocalTournament.find(params[:local_tournament_id])
    @tournament.participants.delete(params[:id])
    @tournament.save
    redirect_to edit_club_local_tournament_path(@tournament.club, @tournament)
  end
end
