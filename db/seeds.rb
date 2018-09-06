# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.new(name: ENV["APP_ADMIN_USERNAME"], email: ENV["APP_ADMIN_EMAIL"], password: ENV["APP_ADMIN_PASSEORD"]).save if !User.find_by(name: ENV["APP_ADMIN_USERNAME"])