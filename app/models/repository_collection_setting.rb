class RepositoryCollectionSetting < ApplicationRecord
  has_one :repository_collection, dependent: :destroy

  enum status: { "Active" => 0, "Running" => 1, "Invalid" => 7, "Error" => 8, "Not Crawled" => 9 }
  
end
