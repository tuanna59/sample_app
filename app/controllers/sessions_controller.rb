class SessionsController < ApplicationController
  def new; end

  def create
    @user = User.find_by email: params[:session][:email].downcase
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in_and_remember
      else
        unactivated_account_process
      end
    else
      flash_error
    end
  end

  def unactivated_account_process
    message = t "controllers.sessions.activation_required_message"
    flash[:warning] = message
    redirect_to root_url
  end

  def log_in_and_remember
    log_in @user
    params[:session][:remember_me] == Settings.remember_me.checked ? remember(@user) : forget(@user)
    redirect_back_or @user
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
