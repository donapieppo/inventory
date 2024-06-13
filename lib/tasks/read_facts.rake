require "net/http"
require "uri"
require "json"

# oppure
# curl -X GET http://puppet8-board.unibo.it:8080/pdb/query/v4/nodes/shib.unibo.it/facts
# curl -X GET  http://puppet8-board.unibo.it:8080/pdb/query/v4/fact-contents --data-urlencode 'query=["and", ["=", "certname", "lcst-ondemand-01.personale.dir.unibo.it"], ["=", "environment", "hpc"]]
# ma ritorna un array di facts meno facile da parsare
# https://www.puppet.com/docs/puppetdb/7/api/query/v4/nodes.html

namespace :inventory do
  namespace :puppet do
    desc "Read node from puppet board"
    task read_facts: :environment do
      uri = URI.parse(Rails.configuration.puppet_facts_uri)
      headers = {Accept: "application/json", "Content-Type": "application/json"}

      Node.where("name like '%ondemand%'").each do |node|
        # Node.where("kernelversion is NULL").each do |node|
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path, headers)

        # q = %(["=", "certname", "#{node.name}"])
        q = %(["and", ["=", "certname", "#{node.name}"], ["=", "environment", "hpc"]])
        request.body = {query: q}.to_json

        response = http.request(request)
        json_response = JSON.parse(response.body)

        next unless json_response.size > 0

        facts = {}
        json_response.each do |fact|
          p fact["name"]
          p fact["value"]
          facts[fact["name"]] = fact["value"]
        end

        memory = if facts["memorysize"]
          facts["memorysize"].split(".")[0]
        else
          facts["memory"]["system"]["total"].split(".")[0]
        end

        ips = []
        facts["networking"]["interfaces"].each do |interface, values|
          next if interface == "lo"
          ips << values["ip"]
        end
        p ips

        File.write("/tmp/facts.yml", facts.to_s)

        node.update!(
          operatingsystem: facts["os"]["name"],
          operatingsystemrelease: (facts["os"]["name"] == "windows") ? facts["os"]["release"]["full"] : facts["os"]["distro"]["release"]["full"],
          kernelversion: facts["kernelversion"],
          processorcount: facts["processors"]["count"],
          memorysize: memory,
          datacenter_zone: facts["datacenter_zone"]
        )

        if facts.key?("open_ports")
          # [{"p"=>"6817", "s"=>"slurmctld"}, {"p"=>"6819", "s"=>"slurmdbd"}, {"p"=>"25", "s"=>"master"}, {"p"=>"22", "s"=>"sshd"}, {"p"=>"111", "s"=>"rpcbind"}]
          facts["open_ports"].each do |service|
            if (s = Software.find_by(name: service["s"]))
              NodeService.find_or_create_by!(node: node, software: s, port: service["p"])
            end
          end
        end

        sleep 3
      end
    end
  end
end

# "os"=>{"name"=>"windows", "family"=>"windows", "release"=>{"full"=>"2019", "major"=>"2019"}
# "os"=>{"name"=>"Ubuntu", "distro"=>{"id"=>"Ubuntu", "release"=>{"full"=>"22.04", "major"=>"22.04"}
