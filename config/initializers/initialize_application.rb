require 'logger'

if ENV["APP_START_FROM"].nil? 
  logger = Rails.logger
  logger.info "initializing application..."
  
  Rails.application.load_tasks
  
  RepositoryCollection.all_enabled.each do |collection|
    id = collection.repository_collection_setting.id
    begin
      Rake::Task["crawl_collections:make_autocomplete"].reenable
      Rake::Task["crawl_collections:make_autocomplete"].invoke(id)  
      logger.info "succeed to invoke: crawl_collections:make_autocomplete, id=#{id}"
    rescue
     logger.error "failed to invoke: crawl_collections:make_autocomplete, id=#{id}"
    end

  end
  logger.info "done."
  
end
