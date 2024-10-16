class NotifierMailer < ApplicationMailer
  def notify_obsolete_os(node)
    @node = node
    @contacts = @node.role.contacts_no_cesia

    mail(to: "pietro.donatini@unibo.it",
      from: "NoReply Sistemi Cesia <notifica.inviodlist.08218@unibo.it>",
      subject: "Avviso scadenza supporto sistema operativo #{@node.name}")
  end
end
