require "net/http"
require "yaml"
require "json"

def parse_upstreams(url)
  uri = URI.parse(url + "/http/upstreams")
  headers = {Accept: "application/json", "Content-Type": "application/json"}

  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.path, headers)

  response = http.request(request)
  JSON.parse(response.body).each do |site_name, conf|
    p site_name

    state = "up"
    requests = 0
    ip_and_ports = []

    conf["peers"].each do |conf|
      state = conf["state"] if conf["state"] != "up"
      requests += conf["requests"]
      ip_and_ports << conf["server"].split(":")
    end

    web_site = WebSite.find_or_initialize_by(name: site_name)
    web_site.arch_requests += web_site.new_requests if requests < web_site.new_requests
    web_site.new_requests = requests
    web_site.state = state
    web_site.save!

    ip_and_ports.each do |ip_and_port|
      web_site.update_ip_association_from_s(ip_and_port[0], ip_and_port[1])
    end
  end
end

def parse_yaml(file)
  ip_regexp = /^(\d{1,3}\.){3}\d{1,3}$/

  yaml_file = File.join(Rails.configuration.puppet_roles_dir, "nginx_fe.yaml")
  conf = YAML.load_file(yaml_file)

  if conf.key? "profile::nginxplus::sites"
    sites = conf["profile::nginxplus::sites"]
    sites.each do |conf_name, conf|
      next if conf_name == "frontend-http-01.unibo.it"
      next if conf.dig("server_options", "return")&.start_with?("301")

      p conf_name
      p conf

      server_name = conf.dig("server_options", "server_name")
      unless server_name.blank? || server_name == "_"
        name = server_name
      end

      # name.split(" ").each do |name|
      # end
      upstream_members = conf["upstream_members"] || []
      pp conf["upstream_members"]

      web_site = WebSite.find_or_create_by!(name: name)

      upstream_members.each do |um|
        ip, port = um.strip.split(" ")&.dig(0)&.split(":")

        if ip.match(ip_regexp)
          web_site.update_ip_association_from_s(ip, port)
        else
          p "NO IP #{ip}"
        end
      end
      p web_site
      p web_site.web_site_addresses
    end
  else
    p "No profile::nginxplus::sites"
  end
end

namespace :inventory do
  namespace :puppet do
    desc "Read sites from nginx-fe.yaml and nginx-be.yaml"
    task read_nginx: :environment do
      # FROM puppet
      # parse_yaml(File.join(Rails.configuration.puppet_roles_dir, "nginx_fe.yaml"))
      # parse_yaml(File.join(Rails.configuration.puppet_roles_dir, "nginx_be.yaml"))

      # FROM ngnix api
      parse_upstreams(Rails.configuration.nginx_frontend_url)
      parse_upstreams(Rails.configuration.nginx_backend_url)
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
#
# "gemma.unibo.it"=>
# {"peers"=>
#    [{"id"=>0,
#     "server"=>"10.11.37.22:3002",
#     "name"=>"10.11.37.22:3002",
#     "backup"=>false,
#     "weight"=>1,
#     "state"=>"up",
#     "active"=>0,
#     "max_conns"=>200,
#     "requests"=>8403,
#     "header_time"=>386,
#     "response_time"=>388,
#     "responses"=>{"1xx"=>0, "2xx"=>5446, "3xx"=>2847, "4xx"=>26, "5xx"=>0, "codes"=>{"200"=>5446, "302"=>2748, "304"=>99, "404"=>16, "422"=>10}, "total"=>8319},
#     "sent"=>12707540,
#     "received"=>203889292,
#     "fails"=>0,
#     "unavail"=>0,
#     "health_checks"=>{"checks"=>0, "fails"=>0, "unhealthy"=>0},
#     "downtime"=>0,
#     "selected"=>"2024-09-04T08:37:09Z"}
#    ],
#  "keepalive"=>0,
#  "zombies"=>0,
#  "zone"=>"gemma.unibo.it"
#  },
#
