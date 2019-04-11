module Rankings
  class RanksController < ApplicationController
    def create
      Delayed::Job.enqueue PlayerRankingJob.new
      redirect_back fallback_location: root_path, notice: 'Re-ranking players. Could take a moment.'
    end

    def collect_points_job
      return unless Rails.env.development?

      Delayed::Job.enqueue CollectPlayerPointsJob.new
      redirect_back fallback_location: root_path, notice: 'Collecting player points. Could take hours.'
    end

    def create_players_with_points_job
      Delayed::Job.enqueue(CreatePlayersWithPointsJob.new)
      redirect_back fallback_location: root_path, notice: 'Creating players. Could take a moment.'
    end
  end
end
