# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180915112843) do

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "title",         limit: 191, null: false
    t.integer  "repository_id",             null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["repository_id"], name: "index_categories_on_repository_id", using: :btree
    t.index ["title", "repository_id"], name: "index_categories_on_title_and_repository_id", unique: true, using: :btree
  end

  create_table "repositories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "url",                      limit: 191,   null: false
    t.string   "name"
    t.string   "author"
    t.string   "license"
    t.integer  "star"
    t.datetime "git_updated_at"
    t.text     "description",              limit: 65535
    t.text     "image_url",                limit: 65535
    t.datetime "crawled_at"
    t.integer  "repository_collection_id",               null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["repository_collection_id"], name: "index_repositories_on_repository_collection_id", using: :btree
    t.index ["url", "repository_collection_id"], name: "index_repositories_on_url_and_repository_collection_id", unique: true, using: :btree
  end

  create_table "repository_collection_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "url"
    t.string   "name"
    t.string   "author"
    t.string   "description"
    t.datetime "crawled_at"
    t.string   "crawl_schedule_weeks"
    t.integer  "status"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "repository_collections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "name"
    t.string   "author"
    t.string   "license"
    t.integer  "star"
    t.datetime "git_updated_at"
    t.datetime "crawled_at"
    t.integer  "repository_collection_setting_id", null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["repository_collection_setting_id"], name: "index_repository_collections_on_repository_collection_setting_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "last_logged_in_at"
  end

  add_foreign_key "categories", "repositories"
  add_foreign_key "repositories", "repository_collections"
  add_foreign_key "repository_collections", "repository_collection_settings"
end
