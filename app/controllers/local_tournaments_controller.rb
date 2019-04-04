class LocalTournamentsController < ApplicationController
  include TeamFormatterConcern

  after_action :allow_iframe, only: :show

  def index
    @local_tournaments = LocalTournament.all
  end

  def new
    @club = Club.find(params[:club_id])
    @local_tournament = @club.local_tournaments.build
  end

  def edit
    @tournament = LocalTournament.find(params[:id])
    authorize! :manage, @tournament
  end

  def show
    @tournament = LocalTournament.find(params[:id])
    authorize! :read, @tournament
    @challonge_tournament = Challonge::Tournament.find(@tournament.challonge_id)
  end

  def create
    @club = Club.find(params[:club_id])
    @local_tournament = @club.local_tournaments.build(local_tournaments_params)
    if @local_tournament.save
      redirect_to club_local_tournament_path(@local_tournament.club_id, @local_tournament.id)
    else
      render 'new'
    end
  end

  def destroy
    @club = Club.find(params[:club_id])
    @local_tournament = LocalTournament.find(params[:id])
    ChallongeApi.delete_tournament(@local_tournament.challonge_id)
    @local_tournament.destroy
    redirect_to club_path(@club)
  end

  def all_local_tournaments
    @local_tournaments = LocalTournament.order(created_at: :desc)
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
    return redirect_to club_local_tournament_path(tournament.club_id, tournament.id) if tournament.started?

    find_or_create_challonge_tournament(tournament)
    ChallongeApi.clear_out_participants(tournament.challonge_id)
    format_teams(tournament)
    challonge_bracket = ChallongeApi.start(tournament.challonge_id)
    tournament.update(started: challonge_bracket.parsed_response.dig('tournament', 'started_at').present?)
    redirect_to club_local_tournament_path(tournament.club, tournament)
  rescue TeamFormatterError => e
    redirect_to edit_club_local_tournament_path(tournament.club, tournament), alert: e
  end

  def find_or_create_challonge_tournament(tournament)
    return Challonge::Tournament.find(tournament.challonge_id) if tournament.challonge_id.present?

    json_response = ChallongeApi.create_tournament(tournament)
    tournament.update(challonge_url: json_response.parsed_response.dig('tournament', 'live_image_url'),
                      challonge_id: json_response.parsed_response.dig('tournament', 'id'))
  end

  def update_challonge_tournament(tournament)
    ChallongeApi.update_tournament(tournament)
  end

  def enter_match_result
    tournament = LocalTournament.find(params[:local_tournament_id])
    challonge_tournament = Challonge::Tournament.find(tournament.challonge_id)
    match = challonge_tournament.matches.find{|match| match.id == params[:match_id].to_i}
    match.scores_csv = '3-1,3-2'
    match.winner_id = params[:match_result][:winner].to_i
    match.save
    redirect_to club_local_tournament_path(tournament.club_id, tournament.id)
  end

  def finalize
    tournament = LocalTournament.find(params[:local_tournament_id])
    challonge_tournament = Challonge::Tournament.find(tournament.challonge_id)
    ChallongeApi.finalize(challonge_tournament.id)
    tournament.update(finished: true)
    redirect_to club_local_tournament_path(tournament.club_id, tournament.id)
  rescue ChallongeApiError => e
    redirect_to club_local_tournament_path(tournament.club_id, tournament.id), alert: e.errors.first
  end

  private

  def local_tournaments_params
    params.require(:local_tournament).permit(:name, :tournament_type, :format)
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
