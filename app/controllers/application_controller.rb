class ApplicationController < ActionController::Base
  include Pagy::Method

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
      result = if user.nil?
        { failure: :invalid_username }
      elsif user.authenticate password
        :success
      else
        { failure: :invalid_password }
      end

      Rails.event.notify("user.authentication_attempt", username: username, result:)

      result == :success ? user : nil
    end
  end
end
