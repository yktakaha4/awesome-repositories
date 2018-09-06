class CollectionsController < ApplicationController
  def index
    @collections = RepositoryCollection.all_enabled
  end

  def show
    @id = params[:id]
    @collection = RepositoryCollection.find_by_id(@id)
    if @collection.nil?
      redirect_to root_path
      return
    end

    @param_order = %w(name author license star last_updated).include?(params[:order]) ? params[:order] : nil
    @param_direction = %w(asc desc).include?(params[:direction]) ? params[:direction] : nil
    if !@param_order.nil? && !@param_direction.nil? then
      order = (@param_order == "last_updated") ? "git_updated_at" : @param_order
      direction = @param_direction
    else
      order = "star"
      direction = "desc"
    end
    
    @param_page = params[:page]

    keywords = []
    if params.has_key?(:item) then
      if params[:item].has_key?(:keywords) then
        keywords = params[:item][:keywords]
      end
    end

    @param_keywords = []
    keyword_names = []
    keyword_authors = []
    keyword_licenses = []
    keyword_descriptions = []
    keyword_categories = []
    keywords.each do |keyword|
      tuple = keyword.split(":", 2)
      if tuple.length == 2 && keywords.length < 10 then
        if tuple[0] == "Name" then
          keyword_names.push(tuple[1])
          @param_keywords.push(keyword)
        elsif tuple[0] == "Author" then
          keyword_authors.push(tuple[1])
          @param_keywords.push(keyword)
        elsif tuple[0] == "Category" then
          keyword_categories.push(tuple[1])
          @param_keywords.push(keyword)
        elsif tuple[0] == "License" then
          keyword_licenses.push(tuple[1])
          @param_keywords.push(keyword)
        elsif tuple[0] == "Description" then
          keyword_descriptions.push(tuple[1])
          @param_keywords.push(keyword)
        end
      end
    end

    @repositories = @collection.repositories.includes(:categories)
    @repositories = @repositories.where(name: keyword_names) if keyword_names.length > 0
    @repositories = @repositories.where(author: keyword_authors) if keyword_authors.length > 0
    @repositories = @repositories.where(:categories => { :title => keyword_categories }) if keyword_categories.length > 0
    @repositories = @repositories.where(license: keyword_licenses) if keyword_licenses.length > 0

    if keyword_descriptions.length > 0 then
      like_query = keyword_descriptions.length.times.map{|d| "LOWER(description) LIKE LOWER(?)" }.join(" OR ")
      like_params = keyword_descriptions.map{|d| "%" + d.gsub(/[%_]/, '\\\\\0') + "%" }
      @repositories = @repositories.where([like_query] + like_params)
    end
    
    @setting = @collection.repository_collection_setting
    @repositories_count = @repositories.count
    @repositories_total_count = @collection.repositories.count
    
    @param_queries = []
    @param_permitted = params
        .permit(:id, :order, :direction, item: [{keywords: []}])
        .merge({:item => {:keywords => @param_keywords}})
    
    @repository_paginate = @repositories.order("#{order} #{direction}, 1").page(@param_page)
    if keyword_categories.length > 0 then
      @repositories = Repository
          .where(id: @repository_paginate.pluck(:id))
          .includes(:categories)
          .order("#{order} #{direction}, 1")
    else
      @repositories = @repository_paginate
    end
    
  end
  
end
