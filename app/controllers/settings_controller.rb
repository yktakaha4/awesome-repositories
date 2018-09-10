class SettingsController < ApplicationController
  require 'uri'
  require 'octokit'
  require 'rake'

  before_action :require_user_logged_in
  before_action :correct_setting, only: [:crawl, :update, :destroy]  

  def index
    @settings = RepositoryCollectionSetting.all
    @new_setting = RepositoryCollectionSetting.new()
  end

  def create
    @settings = RepositoryCollectionSetting.all
    @new_setting = RepositoryCollectionSetting.new(params[:repository_collection_setting].permit(:url))

    if is_valid_url(@new_setting.url)
      if RepositoryCollectionSetting.find_by(url: @repos_info.html_url).nil?
        setting = RepositoryCollectionSetting.new(
            url: @repos_info.html_url, 
            name: @repos_info.name, 
            author: @repos_info.owner.login, 
            description:  "", 
            crawl_schedule_weeks: 7.times.map{"0"}.join,
            status: 9)
        if setting.save
          flash.now[:success] = "Add succeeded as ##{setting.id} ."
          @new_setting = RepositoryCollectionSetting.new()
        else
        end
      else
        flash.now[:danger] = "Already added: #{@repos_info.html_url}"
      end
    end
    render :index
  end

  def crawl
    if !@setting.Running?
      Rake::Task["crawl_collections:crawl"].reenable
      Rake::Task["crawl_collections:crawl"].invoke(@setting.id.to_s)
      
      Rake::Task["crawl_collections:make_autocomplete"].reenable
      Rake::Task["crawl_collections:make_autocomplete"].invoke(@setting.id.to_s)
      
      flash.now[:success] = "Crawl succeeded: #{@setting.id}"
    else
      flash.now[:danger] = "Crawling now: #{@setting.id}"
    end
    redirect_to settings_path
  end

  def update
    if @setting.update(:description => params[:description], :crawl_schedule_weeks => to_weeks_value)
      flash[:success] = "Update succeeded ##{@setting.id} ."
      redirect_to settings_path
    else
      flash.now[:danger] = "Update failed ##{@setting.id} ."
      render :index
    end
  end

  def destroy
    if @setting.destroy
      flash[:success] = "Delete succeeded ##{@setting.id} ."
      redirect_to settings_path
    else
      flash.now[:danger] = "Delete failed ##{@setting.id} ."
      render :index
    end
  end
  
  private
  
  def correct_setting
    @settings = RepositoryCollectionSetting.all
    @new_setting = RepositoryCollectionSetting.new()
    @setting = @settings.find_by_id(params[:id])
    unless @setting
      redirect_to settings_path
    end
  end
  
  def to_weeks_value
    %w(su mo tu we th fr sa).map{|w| params["schedule_#{w}"].presence || "?" }.join()
  end
  
  def is_valid_url(url)
    u = url.strip
    if u.length > 0
      begin
        uri = URI.parse(u)
        paths = uri.path.split("/")
        if paths.length == 3
          repos_url = "#{paths[paths.length - 2]}/#{paths[paths.length - 1]}"
          
          begin
            client = Octokit::Client.new login: ENV["OCTOKIT_LOGIN"], password: ENV["OCTOKIT_PASSWORD"]
            @repos_info = client.repo repos_url
            return true
            
          rescue Octokit::NotFound => ex
            flash.now[:danger] = "Repository not found: #{url}"
          rescue Octokit::ClientError => ex
            flash.now[:danger] = "Raised client error."        
          rescue Octokit::ServerError => ex
            flash.now[:danger] = "Raised server error."
          rescue => ex
            flash.now[:danger] = "Raised unknown error."
          end
        else
          flash.now[:danger] = "Invalid Repository URL: #{url}"
        end      
      rescue => ex
        flash.now[:danger] = "Invalid URL: #{url}"    
      end
      
    else
      flash.now[:danger] = "Enter Repository URL."      
    end

    return false
  end
  
end
