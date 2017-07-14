class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)

      if !params[:session][:target_url].present?
        redirect_back_or root_url
      else
        redirect_back_or params[:session][:target_url]
      end
    else
      flash[:danger] = 'Invalid email/password combination'
      redirect_to (params[:session][:target_url].nil? ?
               login_path : login_path(:target_url => params[:session][:target_url]))
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
