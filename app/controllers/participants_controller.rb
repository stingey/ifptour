class ParticipantsController < ApplicationController
  def create
    @tournament = LocalTournament.find(params[:local_tournament_id])
    if @tournament.participants.map(&:downcase).include?(params[:players][:name]&.downcase)
      redirect_to edit_club_local_tournament_path(@tournament.club, @tournament), alert: 'Names must be unique'
    else
      @tournament.participants << params[:players][:name]
      @tournament.save
      redirect_to edit_club_local_tournament_path(@tournament.club, @tournament)
    end
  end

  def destroy
    @tournament = LocalTournament.find(params[:local_tournament_id])
    @tournament.participants.delete(params[:id])
    @tournament.save
    redirect_to edit_club_local_tournament_path(@tournament.club, @tournament)
  end
end
