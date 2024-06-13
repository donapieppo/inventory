role_reg = Regexp.new 'custom_role\s+=\s+.(.+).include.*(windows|linux)'

namespace :inventory do
  namespace :puppet do
    desc "Read nodes from site.pp"
    task read_site: :environment do
      File.readlines(Rails.configuration.puppet_repo_dir + "/manifests/site.pp")
        .map { |line| line.strip }
        .select { |line| !line.empty? && line[0] != "#" }
        .join
        .split("node ")
        .drop(1)
        .each do |line|
        nodes, roles = line.split "{"

        nodes = nodes.split(/,\s*/)

        role = role_reg.match(roles)

        if role
          r = Role.create!(name: role[1], os: role[2])
          nodes.each do |node|
            Node.create(role_id: r.id, name: node.delete("'").delete('"').strip)
          end
          puts r.name
        end
      end
    end
  end
end
