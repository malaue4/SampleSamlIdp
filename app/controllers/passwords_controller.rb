class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to({ action: :new }, alert: "Try again later.") }

  def new
  end

  def create
    if user = User.find_by(username: params[:username])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to({ action: :new, controller: "sessions" }, notice: "Password reset instructions sent (if user with that username exists).")
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.user_sessions.update_all(expires_at: Time.current)
      redirect_to({ action: :new, controller: "sessions" }, notice: "Password has been reset.")
    else
      redirect_to({ action: :edit, token: params[:token] }, alert: "Passwords did not match.")
    end
  end

  private

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to({ action: :new }, alert: "Password reset link is invalid or has expired.")
    end
end
