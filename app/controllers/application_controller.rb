class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # rescue_from CanCan::AccessDenied, with: ->(exception) { user_not_authorized(exception) }

  def authenticate
    redirect_to rankings_singles_path unless current_user.try(:admin)
  end

  def user_not_authorized(exception)
    redirect_back(fallback_location: root_path, alert: exception.message)
  end
end
