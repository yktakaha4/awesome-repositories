class MonitorMailer < ApplicationMailer
  default from: 'not_reply@example.com'

  def send_monitor_mail(reason)
    @env = Rails.env
    @reason = reason
    @now_date = DateTime.now
    @repository_collection_settings = RepositoryCollectionSetting.all

    to_addresses = User.all.map{|u| u.email }
    subject = "[Monitor]Awesome Repositories (#{@env})"

    mail(to: to_addresses.join(","), subject: subject)
  end
end
