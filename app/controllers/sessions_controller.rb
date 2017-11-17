class SessionsController < ApplicationController
  def new; end

  def create
    @user = User.find_by email: params[:session][:email].downcase
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      params[:session][:remember_me] == Settings.remember_me.checked ? remember(@user) : forget(@user)
      redirect_to @user
    else
      flash_error
    end
  end

  def flash_error
    flash.now[:danger] = t("controllers.sessions.login_error")
    render :new
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
