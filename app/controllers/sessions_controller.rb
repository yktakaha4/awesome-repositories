class SessionsController < ApplicationController
  def new
  end

  def create
    name = params[:session][:id].downcase
    password = params[:session][:password]
    if login(name, password)
      redirect_to settings_url
    else
      flash.now[:danger] = 'Login failed.'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url
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
