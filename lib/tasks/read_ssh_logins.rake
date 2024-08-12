# Jul  8 07:46:17 ldrp-twprx-02 sshd[2395797]: pam_unix(sshd:session): session opened for user personale\xxxx.yyyyy(uid=11111) by (uid=0)
ssh_pattern = Regexp.new '(?<timestamp>\w{3}\s+\d+ \d{2}:\d{2}:\d{2}) (?<host>.*) sshd.*: session opened for user (?<user>.*?)\(uid=\d+\) by'

namespace :inventory do
  namespace :logins do
    desc "Read ssh logins from logs"
    task :read_ssh_logins, [:filename] => :environment do |task, args|
      users_to_skip = ["oracle", "root", "netbox", "deploy", "tutor"]
      user_connections = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }

      File.open(args.filename).each do |line|
        if (match = ssh_pattern.match(line))
          user = match["user"]
          user = user.gsub("personale\\", "")
          unless users_to_skip.include?(user)
            timestamp = DateTime.parse(match["timestamp"])
            if (node = Node.find_by_name("#{match["host"]}.personale.dir.unibo.it"))
              user_connections[user][node].append(timestamp)
            else
              puts "--------- MANCA #{match["host"]}"
            end
          end
        end
      end
      user_connections.each do |username, conns|
        if (user = User.find_by_sam(username))
          puts "#{username} -> #{user.inspect}"
          conns.each do |node, dates|
            p node
            ssh_login = SshLogin.find_or_create_by!(user: user, node: node)
            dates.select! { |d| d > (ssh_login.last_login || 0) }
            ssh_login.update(
              numbers: ssh_login.numbers + dates.count,
              last_login: dates.last
            )
          end
        end
      end
    end
  end
end
