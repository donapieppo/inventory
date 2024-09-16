class AdGroup < ApplicationRecord
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :users

  def to_s
    name
  end

  def contacts
    users.map(&:upn)
  end
end
