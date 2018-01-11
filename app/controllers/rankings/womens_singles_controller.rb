module Rankings
  class WomensSinglesController < BaseController
    def index
      @womens_singles = Player.where(gender: 'F')
      super
    end
  end
end
