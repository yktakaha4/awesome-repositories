class SessionsController < ApplicationController
  def new
  end

  def create
    name = params[:session][:id].downcase
    password = params[:session][:password]
    if login(name, password)
      flash[:success] = 'Login succeeded.'
      redirect_to settings_url
    else
      flash.now[:danger] = 'Login failed.'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = 'Logged out.'
    redirect_to root_url
  end

  private

  def login(name, password)
    @user = User.find_by(name: name)
    if @user && @user.authenticate(password)
      session[:user_id] = @user.id
      return true
    else
      return false
    end
  end
end
