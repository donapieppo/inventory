class HpcGroup < ApplicationRecord
  has_many :hpc_memberships
  has_rich_text :description

  def to_s
    name
  end
end
