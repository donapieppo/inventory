namespace :inventory do
  namespace :puppet do
    desc "Read roles and nodes from site.pp"
    task read_site: :environment do
      role_reg = Regexp.new 'custom_role\s+=\s+.(.+).include.*(windows|linux)'
      site_pp = File.join(Rails.configuration.puppet_repo_dir, "manifests", "site.pp") 

      File.readlines(site_pp)
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
          r = Role.create_with(os: role[2]).find_or_create_by!(name: role[1])
          nodes.each do |node|
            node_name = node.delete("'").delete('"').strip
            Node.create_with(role_id: r.id).find_or_create_by!(name: node_name)
          end
          puts r.name
        end
      end
    end
  end
end
