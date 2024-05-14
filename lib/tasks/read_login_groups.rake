require "yaml"

PUPPET_ROLES_DIR = "/home/dona/puppet-control-repo/data/roles"

namespace :inventory do
  namespace :puppet do
    desc "Read nodes from site.pp"
    task read_login_groups: :environment do
      Role.find_each do |role|
        yaml_role_file = "#{PUPPET_ROLES_DIR}/#{role.name}.yaml"
        if File.exist?(yaml_role_file)
          role_yaml = YAML.load_file("#{PUPPET_ROLES_DIR}/#{role.name}.yaml")
          next unless role_yaml
        else
          next
        end
        admins_groups = os = nil

        if role_yaml.key? "profile::windows::windowsbaseline::login_groups"
          os = "windows"
          admins_groups = role_yaml["profile::windows::windowsbaseline::login_groups"]
        elsif role_yaml.key? "profile::linux::linuxbaseline::login_groups"
          os = "linux"
          admins_groups = role_yaml["profile::linux::linuxbaseline::login_groups"]
        else
          next
        end

        # make it an arry if not already
        admins_groups = [admins_groups] unless admins_groups.is_a?(Array)

        p admins_groups
        admins_groups.each do |r|
          ad_group = AdGroup.find_or_create_by(name: r)
          role.ad_groups << ad_group
        end
      end
    end
  end
end
