require 'logger'

logger = Rails.logger

if ENV["APP_START_FROM"].nil?
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
  
  begin
    MonitorMailer.send_monitor_mail.deliver!
  rescue => e
    logger.warn "failed to send mail..."
    logger.warn e
  end
  
  logger.info "done."
else
  logger.info "skip initializing."
end
