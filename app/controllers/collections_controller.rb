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

    @param_order = %w(name author license star last_update).include?(params[:order]) ? params[:order] : nil
    @param_direction = %w(asc desc).include?(params[:direction]) ? params[:direction] : nil
    if @param_order.nil? || @param_direction.nil? then
      @param_order = "star"
      @param_direction = "desc"
    end
    
    @param_page = params[:page]

    @setting = @collection.repository_collection_setting
    @repositories = @collection.repositories
        .order("#{@param_order} #{@param_direction}")
        .includes(:categories)
        .page(@param_page)
  end
  
end
