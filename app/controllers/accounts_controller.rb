class AccountsController < ApplicationController
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(account_params)
      redirect_to account_path, notice: "Account settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(
      :name_id,
      :name,
      :username,
      :email,
      :phone,
      :password,
      :password_confirmation,
      :password_challenge
    )
  end
end
