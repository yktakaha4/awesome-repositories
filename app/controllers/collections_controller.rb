class CollectionsController < ApplicationController
  def index
    @collections = RepositoryCollection.all_enabled
  end

  def show
    @collection = RepositoryCollection.find_by_id(params[:id])
    if @collection.nil?
      redirect_to root_path
      return
    end
    
    @setting = @collection.repository_collection_setting
    @repositories = @collection.repositories.includes(:categories).page(params[:page])
  end
end
