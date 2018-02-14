module Rankings
  class RanksController < ApplicationController
    def create
      Delayed::Job.enqueue PlayerRankingService.new
      redirect_back fallback_location: root_path, notice: 'Re-ranking players. Could take a moment'
    end
  end
end
