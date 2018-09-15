Cloudinary.config do |config|
  config.cloud_name = ENV["APP_CLOUDINARY_NAME"]
  config.api_key = ENV["APP_CLOUDINARY_API_KEY"]
  config.api_secret = ENV["APP_CLOUDINARY_API_SECRET"]
  config.secure = true
  config.cdn_subdomain = true
end