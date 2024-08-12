require "yaml"

namespace :inventory do
  namespace :puppet do
    desc "Read sites from nginx-fe.yaml"
    task read_nginx: :environment do
      ip_regexp = /^(\d{1,3}\.){3}\d{1,3}$/

      yaml_file = File.join(Rails.configuration.puppet_roles_dir, "nginx_fe.yaml")
      conf = YAML.load_file(yaml_file)

      if conf.key? "profile::nginxplus::sites"
        sites = conf["profile::nginxplus::sites"]
        sites.each do |name, conf|
          p name
          p conf

          next if conf.dig("server_options", "return")&.start_with?("301")
          next if name == "frontend-http-01.unibo.it"

          server_name = conf.dig("server_options", "server_name")
          unless server_name.blank? || server_name == "_"
            name = server_name
          end

          upstream_members = conf["upstream_members"] || []
          pp conf["upstream_members"]

          web_site = WebSite.find_or_create_by!(name: name)

          upstream_members.each do |um|
            ip, port = um.strip.split(" ")&.dig(0)&.split(":")

            if ip.match(ip_regexp)
              web_site.web_site_addresses.find_or_create_by!(ip: ip, port: port.to_i)
            else
              p "NO IP #{ip}"
            end
          end
          p web_site
          p web_site.web_site_addresses

          gets
        end
      else
        p "No profile::nginxplus::sites"
      end
    end
  end
end

# "qrbox-test.unibo.it"
# {"upstream_members"=>["pkbox-test.unibo.it:8443 fail_timeout=10s max_conns=200"],
# "server_options"=>{"listen"=>"frontend-http-01.unibo.it:443 ssl", "server_name"=>"qrbox-test.unibo.it"},
# "locations"=>{"/"=>{"proxy_pass"=>"https://qrbox-test.unibo.it"}},
# "cesia_group"=>"sistemi_identita",
# "enable_maintenance"=>true}

# avng2.unibo.it:
#   server_options:
#     listen: frontend-http-01.unibo.it:443 ssl
#     server_name: avng2.unibo.it
#   locations:
#     '/':
#       proxy_pass: http://137.204.24.103
#   redirect_ssl: true
