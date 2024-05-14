class User < ApplicationRecord
  include DmUniboCommon::User
  has_and_belongs_to_many :ad_groups
  has_many :hpc_memberships
  has_and_belongs_to_many :hpc_groups, through: :hpc_memberships

  # FIXME
  def roles
    ad_groups.map(&:roles).flatten
  end
end
