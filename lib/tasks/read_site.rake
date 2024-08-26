namespace :inventory do
  namespace :puppet do
    desc "Read roles and nodes from site.pp"
    task read_site: :environment do
      role_reg = Regexp.new 'custom_role\s+=\s+.(.+).include.*(windows|linux)'
      site_pp = File.join(Rails.configuration.puppet_repo_dir, "manifests", "site.pp")

      real_node_ids = []
      File.readlines(site_pp)
        .map { |line| line.strip }
        .select { |line| !line.empty? && line[0] != "#" }
        .join
        .split("node ")
        .drop(1)
        .each do |line|
        nodes_str, role_str = line.split "{"
        node_names = nodes_str.split(/,\s*/)
        role_match = role_reg.match(role_str)
        if role_match
          puts "----"
          p role_match
          r = Role.find_or_create_by!(os: role_match[2], name: role_match[1])
          p r
          node_names.each do |node|
            node_name = node.delete("'").delete('"').strip
            p node_name
            node = Node.find_or_create_by!(role_id: r.id, name: node_name)
            real_node_ids << node.id
          end
        end
      end

      Node.where.not(id: real_node_ids).each do |node|
        puts "---- DELETE ----"
        p node
        puts "Can delete?"
        if gets.chomp == "yes"
          node.destroy
        else
          puts "no"
        end
      end
    end
  end
end
