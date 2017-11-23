class PasswordResetsController < ApplicationController
  before_action :find_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "controllers.password_reset.email_sent_message"
      redirect_to root_url
    else
      flash.now[:danger] = t "controllers.password_reset.email_not_found_message"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("controllers.password_reset.password_blank_message")
      render :edit
    elsif @user.update_attributes user_params
      update_successful_process
    else
      render :edit
    end
  end

  def update_successful_process
    log_in @user
    @user.update_attribute :reset_digest, nil
    flash[:success] = t "controllers.password_reset.password_reset_successful"
    redirect_to @user
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def find_user
    @user = User.find_by email: params[:email]
  end

  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "controllers.password_reset.password_reset_expired"
    redirect_to new_password_reset_url
  end
end
