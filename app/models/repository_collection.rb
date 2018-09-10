class RepositoryCollection < ApplicationRecord
  belongs_to :repository_collection_setting
  has_many :repositories, dependent: :destroy
  
  def repositories_count
    repositories.count
  end
  
  def self.all_enabled
    RepositoryCollection
        .joins(:repository_collection_setting)
        .where(repository_collection_settings: { status: [0, 1] })
        .order("git_updated_at desc")
  end
  
end
