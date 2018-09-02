class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :repositories do |t|
      t.string :url, :null => false, :limit => 191
      t.string :name
      t.string :author
      t.string :license
      t.integer :star
      t.datetime :git_updated_at
      t.text :description
      t.string :image_url
      t.datetime :crawled_at
      t.references :repository_collection, :null => false, foreign_key: true

      t.timestamps

      t.index [:url, :repository_collection_id], unique: true
    end
  end
end
