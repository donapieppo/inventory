class Role < ApplicationRecord
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :ad_groups
  has_many :nodes

  has_rich_text :description

  def to_s
    name
  end

  def pp_file
    Rails.configuration.puppet_repo_dir + "/site/role/manifests/#{os}/#{name}.pp"
  end
end
