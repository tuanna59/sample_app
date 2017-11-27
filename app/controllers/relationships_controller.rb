class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by id: params[:followed_id]
    if @user
      current_user.follow @user
      button_process
    else
      not_found_user
    end
  end

  def destroy
    @user = Relationship.find_by(id: params[:id]).followed
    if @user
      current_user.unfollow @user
      button_process
    else
      not_found_user
    end
  end

  def button_process
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def not_found_user
    flash[:danger] = t "controllers.users.not_found_message"
    redirect_to root_url
  end
end
