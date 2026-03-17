class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  def current_user
    @current_user ||= authenticate_user!
  end
  helper_method :current_user

  private

  def authenticate_user!
    @current_user = authenticate_or_request_with_http_basic("management", "Alakazam?") do |username, password|
      user = User.find_by(username: username)
      user if user&.authenticate password
    end
  end
end
