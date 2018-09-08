class RepositoryCollectionSetting < ApplicationRecord
  has_one :repository_collection, dependent: :destroy
  
end
