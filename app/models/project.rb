class Project < ApplicationRecord
  has_and_belongs_to_many :roles
  has_rich_text :description
end
