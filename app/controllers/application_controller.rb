class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action do
    authenticate_or_request_with_http_basic("management", "Alakazam?") do |username, password|
      user = User.find_by(username: username)
      user&.authenticate password
    end
  end

  def current_user
    nil
  end
end
