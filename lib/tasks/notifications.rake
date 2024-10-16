namespace :inventory do
  namespace :notification do
    desc "Notify obsolete os"
    task notify_obsolete_os: :environment do
      Node.includes(role: :ad_groups).where("operatingsystem = ? and operatingsystemrelease <= ?", "ubuntu", "16.04").find_each do |node|
        m = NotifierMailer.notify_obsolete_os(node)
        p m
        m.deliver_now
        raise "ciao"
      end
    end
  end
end
