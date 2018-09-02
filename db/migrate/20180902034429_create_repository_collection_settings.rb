class CreateRepositoryCollectionSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :repository_collection_settings do |t|
      t.string :url
      t.string :name
      t.string :author
      t.string :description
      t.datetime :crawled_at
      t.string :crawl_schedule_weeks
      t.integer :status

      t.timestamps
    end
  end
end
