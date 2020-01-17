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
    redirect_to club_local_tournament_path(@tournament.club, @tournament) unless @tournament.signing_up?
  end

  # def show
  #   @tournament = LocalTournament.find(params[:id])
  #   @challonge_tournament = ChallongeApi.find_tournament(@tournament.challonge_id)
  #   @tournament_matches_by_round = ChallongeApi.find_matches(@tournament.challonge_id).select{ |match| match.dig('match', 'state') == 'open' }.group_by {|match| match['match']['round']}
  # end

  def show
    @tournament = LocalTournament.find(params[:id])
    @matches = @tournament.tournament_hash
  end

  def create
    @club = Club.find(params[:club_id])
    @local_tournament = @club.local_tournaments.new(local_tournaments_params)
    if @local_tournament.save
      redirect_to edit_club_local_tournament_path(@local_tournament.club, @local_tournament)
    else
      render 'new'
    end
  end

  def destroy
    @club = Club.find(params[:club_id])
    @local_tournament = LocalTournament.find(params[:id])
    @local_tournament.destroy
    redirect_to club_path(@club)
  end

  def submit_winner
    @local_tournament = LocalTournament.find(params[:local_tournament_id])
    round = match_params[:round_id]
    match = match_params[:match_id]
    winner = match_params[:winner]
    if round == 'round_5'
      @local_tournament.setup_final(round, match, winner)
    elsif round == 'round_6'
      @local_tournament.record_results(round, match, winner)
    else
      @local_tournament.map_the_win(round, match, winner, check_for_byes: true)
      @local_tournament.map_the_loss(round, match, winner, check_for_byes: true)
    end

    redirect_to club_local_tournament_path(@local_tournament.club, @local_tournament)
  end

  def all_local_tournaments
    @local_tournaments = LocalTournament.order(created_at: :desc)
  end

  def start_tournament
    @tournament = LocalTournament.find(params[:local_tournament_id])
    @tournament.update(tournament_hash: double_draw_your_partner(@tournament), status: LocalTournament.statuses[:started])
    4. times do # run 4 times because tournament_hash changes each time
      @tournament.fill_out_byes
    end
    @tournament.shrink_bracket
    redirect_to club_local_tournament_path(@tournament.club, @tournament)
  end

  # def generate_tournament
  #   tournament = LocalTournament.find(params[:local_tournament_id])
  #   return redirect_to club_local_tournament_path(tournament.club_id, tournament.id) if tournament.started?

  #   find_or_create_challonge_tournament(tournament)
  #   ChallongeApi.clear_out_participants(tournament.challonge_id)
  #   format_teams(tournament)
  #   challonge_bracket = ChallongeApi.start(tournament.challonge_id)
  #   tournament.update(status: LocalTournament.statuses[:started]) if challonge_bracket.parsed_response.dig('tournament', 'started_at').present?
  #   redirect_to club_local_tournament_path(tournament.club, tournament)
  # rescue TeamFormatterError => e
  #   redirect_to edit_club_local_tournament_path(tournament.club, tournament), alert: e
  # end

  def find_or_create_challonge_tournament(tournament)
    return ChallongeApi.find_tournament(tournament.challonge_id) if tournament.challonge_id.present?

    json_response = ChallongeApi.create_tournament(tournament)
    tournament.update(challonge_url: json_response.parsed_response.dig('tournament', 'live_image_url'),
                      challonge_id: json_response.parsed_response.dig('tournament', 'id'))
  end

  def update_challonge_tournament(tournament)
    ChallongeApi.update_tournament(tournament)
  end

  def enter_match_result
    tournament = LocalTournament.find(params[:local_tournament_id])
    scores_csv = '3-1,3-2'
    winner_id = params[:match_result][:winner].to_i
    ChallongeApi.update_match(tournament.challonge_id, params[:match_result][:match_id], winner_id, scores_csv)
    redirect_to club_local_tournament_path(tournament.club_id, tournament.id)
  end

  # def finalize
  #   tournament = LocalTournament.find(params[:local_tournament_id])
  #   ChallongeApi.finalize(tournament.challonge_id)
  #   tournament.update(status: LocalTournament.statuses[:finished])
  #   redirect_to club_local_tournament_path(tournament.club_id, tournament.id)
  # rescue ChallongeApiError => e
  #   redirect_to club_local_tournament_path(tournament.club_id, tournament.id), alert: e.errors.first
  # end

  private

  def match_params
    params.require(:match_result).permit(:round_id, :match_id, :winner)
  end

  def local_tournaments_params
    params.require(:local_tournament).permit(:name, :tournament_type, :format)
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
