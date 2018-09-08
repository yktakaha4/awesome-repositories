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
      @user.last_logged_in_at = @user.updated_at
      if @user.save
        session[:user_id] = @user.id
        return true
      end
    end
    return false
  end
end
