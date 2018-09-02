class RepositoryCollection < ApplicationRecord
  belongs_to :repository_collection_setting
  has_many :repositories
end
