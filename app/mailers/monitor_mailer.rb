class MonitorMailer < ApplicationMailer
  default from: 'not_reply@example.com'

  def send_monitor_mail
    to_addresses = User.all.map{|u| u.email }
    subject = "[Monitor]Awesome Repositories"
    
    @now_date = DateTime.now
    @repository_collection_settings = RepositoryCollectionSetting.all

    mail(to: to_addresses.join(","), subject: subject)
  end
end
