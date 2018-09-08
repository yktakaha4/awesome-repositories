namespace :crawl_collections do
  require 'octokit'
  require 'nokogiri'
  
  desc "crawl_if_scheduled"
  task :crawl_if_scheduled do
    puts "Hello World"
  end
  
  desc "crawl"
  task :crawl, ["setting_id"] => :environment do |task, args|
    now = DateTime.now
    setting_id = args.setting_id
    
    p "start crawling: now=#{now}, setting_id=#{setting_id}"
    RepositoryCollectionSetting.transaction do
      repos_col_setting = RepositoryCollectionSetting.find(setting_id)
      repos_col_setting.status = 1
      repos_col_setting.save!
    end
    
    begin
      RepositoryCollectionSetting.transaction do
        RepositoryCollection.transaction(requires_new: true) do
          Repository.transaction(requires_new: true) do
            repos_col_setting = RepositoryCollectionSetting.find(setting_id)
            repos_col_setting.crawled_at = now
            repos_col_setting.status = 0
            repos_col_setting.save!
    
            client = Octokit::Client.new login: ENV["OCTOKIT_LOGIN"], password: ENV["OCTOKIT_PASSWORD"]
            git_repos_col_url = "#{repos_col_setting.author}/#{repos_col_setting.name}"
            git_repos_col = client.repo git_repos_col_url
    
            repos_col = RepositoryCollection.find_or_initialize_by(repository_collection_setting_id: repos_col_setting.id)
            if repos_col.git_updated_at == git_repos_col[:updated_at]
              p "latest repository collection: author/name=#{git_repos_col_url}"
              repos_col.crawled_at = now
              repos_col.save!
              next
            end
            
            repos_col.name = git_repos_col[:name]
            repos_col.author = git_repos_col[:owner][:login]
            if (git_repos_col[:license].nil?) 
              repos_col.license = "Unknown"
            else
              repos_col.license = git_repos_col[:license][:name]
            end            
            repos_col.star = git_repos_col[:stargazers_count]
            repos_col.git_updated_at = git_repos_col[:updated_at]
            repos_col.crawled_at = now
            repos_col.save!
    
            readme = client.readme git_repos_col_url, :accept => 'application/vnd.github.html'
            doc = Nokogiri::HTML(readme)
            doc.css('a').each do |node|
              begin
                attributes = node.attributes
                url = URI.parse(attributes["href"].value)
                paths = url.path.split("/")
  
                if url.host != "github.com" 
                  next
                elsif paths.length != 3 
                  next
                end
  
                parent_node = node.parent
                node.remove
                
                author = paths[1]
                name = paths[2]
                description = parent_node.content.gsub(/^[\s\-]+|[\s\-]+$/, "")
                
                p "url: #{url.to_s}"
                
                git_repos_url = "#{author}/#{name}"          
                git_repos = client.repo git_repos_url
                url = git_repos[:html_url]
                
                repos = Repository.find_or_initialize_by(url: url, repository_collection_id: repos_col.id)
                if repos.git_updated_at == git_repos[:updated_at]
                  p "latest repository: url=#{url}"
                  repos.crawled_at = now
                  repos.save!
                  next
                end
                
                repos.url = url
                repos.name = name
                repos.author = author
                if (git_repos[:license].nil?) 
                  repos.license = "Unknown"
                else
                  repos.license = git_repos[:license][:name]
                end
                repos.star = git_repos[:stargazers_count]
                repos.git_updated_at = git_repos[:updated_at]
                repos.description = description
                repos.image_url = ""
                repos.crawled_at = now
                
                category_node = parent_node
                headers = ["h1", "h2", "h3", "h4", "h5", "h6", "h7"]
                regex = Regexp.new headers.map{|h| "^" + h + "$"}.join("|")
                category_titles = []
  
                while(!category_node.nil? && category_node.name != "document")
                  tag_name = category_node.name.downcase
                  
                  if headers.length > 0
                    if regex === tag_name 
                      category_titles.push(category_node.content)
                      headers = headers.slice(0, headers.index(tag_name))
                      regex = Regexp.new headers.map{|h| "^" + h + "$"}.join("|")
                    end
                  end
                  
                  if (category_node.previous.nil?) 
                    category_node = category_node.parent
                  else
                    category_node = category_node.previous
                  end
                end
                
                repos.categories.destroy_all
                category_titles.each do |title|
                  repos.categories.build(title: title)
                end
                
                repos.save!
  
              rescue => e
                p "----- repository exception -----"
                puts e.message
                p "----- repository exception -----"
              end
              
            end
  
            destroyed_records = Repository.where("repository_collection_id = ? and crawled_at != ?", repos_col.id, now)
            unless destroyed_records.all?(&:destroyed?)
              raise ActiveRecord::Rollback
            end
          end
          
        end
    
      end
      
      p "finish crawling: now=#{now}, setting_id=#{setting_id}"    
      
    rescue => e
      RepositoryCollectionSetting.transaction do
        repos_col_setting = RepositoryCollectionSetting.find(setting_id)
        repos_col_setting.status = 8
        repos_col_setting.save!
      end
      p e
      p "failed crawling: now=#{now}, setting_id=#{setting_id}"

    end
    
  end
  
  desc "make autocomplete"
  task :make_autocomplete, ["setting_id"] => :environment do |task, args|
    setting_id = args.setting_id

    collection = RepositoryCollectionSetting
      .find(setting_id)
      .repository_collection
      
    if !collection.nil?
      source = collection
        .repositories
        .includes(:categories)
        .flat_map{|r| [
          "Name:" + r.name, 
          "Author:" + r.author, 
          "License:" + r.license 
          ] + r.categories.map{|c| "Category:" + c.title } }.uniq.sort
    else
      source = []
    end

    File.write(
      Rails.root.join("public/autocomplete", "#{collection.id.to_s}.js"), 
      "window.autocomplete_source = #{source.to_json.html_safe};")
  end

end
