class ParticipantsController < ApplicationController
  def create
    @tournament = LocalTournament.find(params[:local_tournament_id])
    @tournament.participants << params[:players][:name]
    if @tournament.save
      redirect_to edit_club_local_tournament_path(@tournament.club, @tournament)
    else
      redirect_to edit_club_local_tournament_path(@tournament.club, @tournament), alert: @tournament.errors.messages[:base].first
    end
  end

  def destroy
    @tournament = LocalTournament.find(params[:local_tournament_id])
    @tournament.participants.delete(params[:id])
    @tournament.save
    redirect_to edit_club_local_tournament_path(@tournament.club, @tournament)
  end
end
