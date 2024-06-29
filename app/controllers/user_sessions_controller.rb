class UserSessionsController < ApplicationController
  # add potential parent resources here
  # load_and_authorize_resource :parent
  load_and_authorize_resource # through: :parent

  # GET /user_sessions
  def index
    @pagy, @user_sessions = pagy(@user_sessions)
  end

  # GET /user_sessions/1
  def show
  end

  # GET /user_sessions/new
  def new
  end

  # GET /user_sessions/1/edit
  def edit
  end

  # POST /user_sessions
  def create
    if @user_session.save
      redirect_to @user_session, notice: "User session was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_sessions/1
  def update
    if @user_session.update(user_session_params)
      redirect_to @user_session, notice: "User session was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /user_sessions/1
  def destroy
    @user_session.destroy!
    redirect_to user_sessions_url, notice: "User session was successfully destroyed.", status: :see_other
  end

  private

    # Only allow a list of trusted parameters through.
    def user_session_params
      params.require(:user_session).permit(:user_id, :expires_at)
    end
end
