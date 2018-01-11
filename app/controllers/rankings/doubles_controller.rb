module Rankings
  class DoublesController < BaseController
    def index
      @doubles = Player.all
      super
    end
  end
end
