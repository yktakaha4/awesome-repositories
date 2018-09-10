require 'logger'

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
   logger.info "failed to invoke: crawl_collections:make_autocomplete, id=#{id}"
  end

end
logger.info "done."