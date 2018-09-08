p "initializing application..."
Rails.application.load_tasks

RepositoryCollection.all_enabled.each do |collection|
  id = collection.repository_collection_setting.id
  begin
    Rake::Task["crawl_collections:make_autocomplete"].reenable
    Rake::Task["crawl_collections:make_autocomplete"].invoke(id)  
  rescue
  end

end
p "done."