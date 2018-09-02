class CreateRepositoryCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :repository_collections do |t|
      t.string :name
      t.string :author
      t.string :license
      t.integer :star
      t.datetime :git_updated_at
      t.datetime :crawled_at
      t.references :repository_collection_setting, null: false, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
