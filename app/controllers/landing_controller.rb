class LandingController < ApplicationController
  def index
    @photos = Photo.all
  end
end
