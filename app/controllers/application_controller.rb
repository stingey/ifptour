class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authenticate
    redirect_to rankings_singles_path unless current_user.try(:admin)
  end
end
