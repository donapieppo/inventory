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
          puts "----"
          p role
          r = Role.find_or_create_by!(os: role[2], name: role[1])
          p r
          nodes.each do |node|
            node_name = node.delete("'").delete('"').strip
            p node_name
            Node.find_or_create_by!(role_id: r.id, name: node_name)
          end
        end
      end
    end
  end
end
