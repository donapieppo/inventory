require "elasticsearch"

def elastic_client
  Elasticsearch::Client.new(
    host: ENV["ELASTIC_HOST"],
    transport_options: {ssl: {verify: false}},
    api_key: {
      id: ENV["ELASTIC_ID"],
      api_key: ENV["ELASTIC_KEY"]
    }
  )
end

namespace :inventory do
  namespace :logins do
    desc "Read logins from elastic api"
    task read_elastic: :environment do
      users_to_skip = ["oracle", "root", "netbox", "deploy", "tutor"]

      client = elastic_client
      Node.where("name=?", "lnvp-node-02.hpc.unibo.it").each do |node|
        aggs = {totals: {terms: {field: "remote_user.keyword"}}}
        query = {term: {"host.keyword": node.name}}
        r = client.search(index: "log-sistemi", body: {size: 0, aggs: aggs, query: query})
        r.body["aggregations"]["totals"]["buckets"].each do |bucket|
          # {"key"=>"pietro.donatini", "doc_count"=>2}
          username = bucket["key"]

          next if users_to_skip.include?(username)

          ssh_totals = bucket["doc_count"]
          last_login = client.search(index: "log-sistemi", body: {
            size: 1,
            sort: [{"@timestamp": {order: "desc"}}],
            query: {
              bool: {
                must: [
                  {term: {"host.keyword": node.name}},
                  {term: {"remote_user.keyword": username}}
                ]
              }
            }
          })

          user = User.find_by_sam(username) || AdmUser.find_by_sam(username) || User.find_by_upn(username)
          if user
            p user
            p ssh_totals
            p last_login.body["hits"]["hits"][0]["_source"]["@timestamp"]
            SshLogin.find_or_create_by!(user: user, node: node).update(
              numbers: ssh_totals,
              last_login: last_login.body["hits"]["hits"][0]["_source"]["@timestamp"]
            )
          else
            puts "MISSING #{username} in DB."
          end
        end
      end
    end
  end
end
