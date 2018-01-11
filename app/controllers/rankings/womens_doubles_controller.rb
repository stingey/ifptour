module Rankings
  class WomensDoublesController < BaseController
    def index
      @womens_doubles = Player.where(gender: 'F')
      super
    end
  end
end
