class LocalTournamentsController < ApplicationController
  after_action :allow_iframe, only: :live_tournament

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

  def add_player
    tournament = LocalTournament.find(params[:local_tournament_id])
    tournament.participants << params[:players][:name]
    tournament.save
    redirect_to club_local_tournament_path(tournament.club, tournament)
  end

  def remove_player
    tournament = LocalTournament.find(params[:local_tournament_id])
    tournament.participants.delete(params[:player_name])
    tournament.save
    redirect_to club_local_tournament_path(tournament.club, tournament)
  end

  def generate_tournament
    tournament = LocalTournament.find(params[:local_tournament_id])
    return redirect_to club_local_tournament_live_tournament_path(tournament.club_id, tournament.id) unless tournament.challonge_url.blank?
    t = Challonge::Tournament.new
    t.name = tournament.name
    t.url = tournament.unique_url
    t.tournament_type = tournament.tournament_type
    t.quick_advance = true
    t.show_rounds = true
    t.save
    tournament.participants.each do |participant|
      Challonge::Participant.create(:name => participant.titleize, :tournament => t)
    end
    t.start!
    tournament.update(challonge_url: t.live_image_url, challonge_id: t.id)

    redirect_to club_local_tournament_live_tournament_path(tournament.club_id, tournament.id)
  end

  def live_tournament
    @tournament = LocalTournament.find(params[:local_tournament_id])
    @challonge_tournament = Challonge::Tournament.find(@tournament.challonge_id)
  end

  def enter_match_result
    tournament = LocalTournament.find(params[:local_tournament_id])
    challonge_tournament = Challonge::Tournament.find(tournament.challonge_id)
    match = challonge_tournament.matches.find{|match| match.id == params[:match_id].to_i}
    match.scores_csv = '3-1,3-2'
    match.winner_id = params[:match_result][:winner].to_i
    match.save
    redirect_to club_local_tournament_live_tournament_path(tournament.club_id, tournament.id)
  end

  def finalize
    tournament = LocalTournament.find(params[:local_tournament_id])
    challonge_tournament = Challonge::Tournament.find(tournament.challonge_id)
    ChallongeApi.finalize(challonge_tournament.id)
    redirect_to club_local_tournament_live_tournament_path(tournament.club_id, tournament.id)
  end

  private

  def local_tournaments_params
    params.require(:local_tournament).permit(:name)
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
