namespace :crawl_collections do
  require 'octokit'
  require 'nokogiri'
  require 'logger'

  desc "crawl_if_scheduled"
  task :crawl_if_scheduled, ["setting_id"] => :environment do |task, args|
    logger = Rails.logger
    
    now = DateTime.now
    logger.info "start checking: now=#{now}"
    RepositoryCollectionSetting.all.select{|s| 
      s.crawl_schedule_weeks[DateTime.now.wday] == "1"
    }.each{|s|
      Rake::Task["crawl_collections:crawl"].invoke(s.id)
    }
    logger.info "end checking: now=#{now}"
    
    begin
      MonitorMailer.send_monitor_mail("Crawled by scheduler").deliver!
    rescue => e
      logger.warn "failed to send mail"
      logger.warn e
    end
  end
  
  desc "crawl"
  task :crawl, ["setting_id"] => :environment do |task, args|
    logger = Rails.logger

    now = DateTime.now
    setting_id = args.setting_id
    
    logger.info "start crawling: now=#{now}, setting_id=#{setting_id}"
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
              if repos_col_setting.Active?
                logger.info "latest repository collection: author/name=#{git_repos_col_url}"
                repos_col.crawled_at = now
                repos_col.save!
                next
              end
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
                
                logger.info "url: #{url.to_s}"
                
                git_repos_url = "#{author}/#{name}"          
                git_repos = client.repo git_repos_url
                url = git_repos[:html_url]
                
                repos = Repository.find_or_initialize_by(url: url, repository_collection_id: repos_col.id)
                if repos.git_updated_at == git_repos[:updated_at]
                  logger.info "latest repository: url=#{url}"
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
                repos.crawled_at = now
                
                git_repos_readme = client.readme git_repos_url, :accept => 'application/vnd.github.html'
                git_repos_doc = Nokogiri::HTML(git_repos_readme)
                begin
                  image_url = git_repos_doc.css("img").map{|n|
                    v = n.attributes["src"].value
                    begin
                      if URI.parse(v).scheme.nil?
                        URI.join(url, v)
                      else
                        v
                      end
                    rescue
                      v
                    end
                  }.sort{|a, b|
                    if a.downcase.end_with?(".gif") || b.downcase.end_with?(".gif")
                      a.downcase.end_with?(".gif") ? -1 : 1
                    elsif a.match("\.[^.]+$").nil? || b.match("\.[^.]+$").nil?
                      !a.match("\.[^.]+$").nil? ? -1 : 1
                    else
                      0
                    end
                  }.find{|u|
                    size = FastImage.size(u)
                    if !size.nil?
                      size[0] >= 50 && size[1] >= 50
                    else
                      false
                    end
                  }
                  
                  public_id = "repos_images/#{repos_col.author}_#{repos_col.name}/#{repos.author}_#{repos.name}"
                  if !image_url.nil?
                    if image_url != repos.image_url
                      search_result = Cloudinary::Search.expression("public_id: #{public_id}").max_results(1).execute
                      if search_result["total_count"].nil?
                        logger.info "upload image: #{public_id}"
                        Cloudinary::Uploader.upload(image_url, 
                            :public_id => public_id, 
                            :width => 200, :crop => :scale)
                      end
                    else
                      logger.info "image already uploaded: #{public_id}"
                    end
                  else
                    if !repos.image_url.blank?
                      logger.info "(dummy) delete image: #{public_id}"
                      # Cloudinary::Uploader.destroy(public_id)
                    end
                  end
                  repos.image_url = image_url

                rescue
                  logger.warn "failed to get image url..."
                  repos.image_url = nil
                end

                category_node = parent_node
                headers = ["h1", "h2", "h3", "h4", "h5", "h6", "h7"]
                regex = Regexp.new headers.map{|h| "^" + h + "$"}.join("|")
                category_titles = []
  
                while(!category_node.nil? ? category_node.name != "document" : false)
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
                logger.error "----- repository exception -----"
                logger.error e.message
                logger.error e.backtrace.join("\n")
                logger.error "----- repository exception -----"
              end
              
            end
  
            destroyed_records = Repository.where("repository_collection_id = ? and crawled_at != ?", repos_col.id, now)
              .includes(:categories)
              .destroy_all
            unless destroyed_records.all?(&:destroyed?)
              raise ActiveRecord::RecordInvalid
            end
            
            p repos_col.repositories.length
            if repos_col.repositories.length == 0
              repos_col_setting = RepositoryCollectionSetting.find(setting_id)
              repos_col_setting.status = 7
              repos_col_setting.save!
            end
          end
          
        end
    
      end
      
      logger.info "finish crawling: now=#{now}, setting_id=#{setting_id}"    
      
    rescue => e
      RepositoryCollectionSetting.transaction do
        repos_col_setting = RepositoryCollectionSetting.find(setting_id)
        repos_col_setting.status = 8
        repos_col_setting.save!
      end
      logger.error e
      logger.error "failed crawling: now=#{now}, setting_id=#{setting_id}"

    end
    
  end
  
  desc "make autocomplete"
  task :make_autocomplete, ["setting_id"] => :environment do |task, args|
    logger = Rails.logger

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

      File.write(
        Rails.root.join("public/autocomplete", "#{collection.id.to_s}.js"), 
        "window.autocomplete_source = #{source.to_json.html_safe};")
    end
    
  end

end
