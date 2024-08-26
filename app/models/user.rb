class User < ApplicationRecord
  include DmUniboCommon::User
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :ad_groups
  has_many :ssh_logins
  has_many :adm_users

  # FIXME
  def roles
    ad_groups.map(&:roles).flatten
  end

  def name_and_upn
    cn + " (#{upn})"
  end
end
