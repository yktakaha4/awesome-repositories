class RepositoryCollection < ApplicationRecord
  belongs_to :repository_collection_setting
  has_many :repositories
  
  def repositories_count
    RepositoryCollection.first.repositories.count
  end
  
  def self.all_enabled
    RepositoryCollection
        .joins(:repository_collection_setting)
        .where(repository_collection_settings: { status: 0 })
        .order("git_updated_at desc")
  end
  
end
