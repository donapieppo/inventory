require "yaml"

# reads admins_groups from role yaml. default is amm.sistemi
namespace :inventory do
  namespace :puppet do
    desc "Read login groups from each role.yaml"
    task read_login_groups: :environment do
      # resettiamo tutte le relazioni tra gruppi e ruoli
      ActiveRecord::Base.connection.execute("TRUNCATE ad_groups_roles")

      Role.find_each do |role|
        admins_groups = "amm.sistemi"

        yaml_role_file = File.join(Rails.configuration.puppet_roles_dir, "#{role.name}.yaml")

        if File.exist?(yaml_role_file)
          if (role_yaml = YAML.load_file(yaml_role_file))
            if role_yaml.key? "profile::windows::windowsbaseline::login_groups"
              admins_groups = role_yaml["profile::windows::windowsbaseline::login_groups"]
            elsif role_yaml.key? "profile::linux::linuxbaseline::login_groups"
              admins_groups = role_yaml["profile::linux::linuxbaseline::login_groups"]
            end
          end
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
