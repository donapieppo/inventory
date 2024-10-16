class Role < ApplicationRecord
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :ad_groups
  has_many :nodes

  has_rich_text :description

  validates :name, uniqueness: true

  def to_s
    name
  end

  def pp_file
    Rails.configuration.puppet_repo_dir + "/site/role/manifests/#{os}/#{name}.pp"
  end

  def yaml_file
    Rails.configuration.puppet_repo_dir + "/data/roles/#{name}.yaml"
  end

  def pp_content
    if File.exist?(pp_file)
      File.read(pp_file)
    end
  end

  def yaml_content
    if File.exist?(yaml_file)
      File.read(yaml_file)
    end
  end

  def contacts_no_cesia
    role.ad_groups.to_a.select { |ad| ad.name != "amm.sistemi" }.each_with_object([]) do |ad_group, res|
      res << ad_group.contacts
    end.flatten.uniq
  end
end
