class Repository < ApplicationRecord
  belongs_to :repository_collection
  has_many :categories
end
