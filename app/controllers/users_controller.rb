class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  before_action :find_user, only: %i(show destroy following followers)

  def index
    @users = User.activated.paginate page: params[:page]
  end

  def show
    if @user.activated?
      @microposts = @user.microposts.ordered_by_date.paginate page: params[:page]
    else
      flash[:info] = t "controllers.users.unactivated_account_message"
      redirect_to root_url
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "controllers.users.activation_required_message"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "controllers.users.profile_update_success_message"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "controllers.users.delete_success_message"
    else
      flash[:danger] = t "controllers.users.delete_failed_message"
    end
    redirect_to users_url
  end

  def following
    @title = t "following"
    @users = @user.following.paginate page: params[:page]
    render "show_follow"
  end

  def followers
    @title = t "followers"
    @users = @user.followers.paginate page: params[:page]
    render "show_follow"
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def correct_user
    @user = User.find_by id: params[:id]
    return if current_user? @user
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?
    redirect_to root_path
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "controllers.users.not_found_message"
    redirect_to root_path
  end
end
