# rankings controller
module Rankings
  # other thing
  class BaseController < ApplicationController
    protected

    def index
    end

    def show
    end

    private

    def singles?
      controller_name.include?('singles')
    end
  end
end
