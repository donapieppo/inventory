class User < ApplicationRecord
  include DmUniboCommon::User
  has_and_belongs_to_many :ad_groups

  # FIXME
  def roles
    ad_groups.map(&:roles).flatten
  end
end
