module Rankings
  class SinglesController < BaseController
    def index
      @singles = Player.all
      super
    end
  end
end
