class Project < ApplicationRecord
  has_and_belongs_to_many :users
  has_and_belongs_to_many :agreements
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :nodes
  has_rich_text :description

  has_many :important_dates, as: :datable

  validates :name, uniqueness: true

  def to_s
    name
  end
end
