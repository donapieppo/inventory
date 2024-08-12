require "net/ldap"

def account?(entry)
  entry[:objectclass].include?("organizationalPerson")
end

namespace :inventory do
  namespace :puppet do
    desc "FIX SamAccountName"
    task fix_users: :environment do
      ldap = Net::LDAP.new host: AD_SERVER, port: 389, auth: {method: :gssapi, hostname: AD_SERVER}
      ldap.bind

      User.find_each do |user|
        filter = Net::LDAP::Filter.eq("userprincipalname", user.upn)
        ldap.search(base: TREEBASE, filter: filter) do |entry|
          if account?(entry)
            # CN=Michele Montani,OU=Sistemi,OU=Utenti-Adm,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it
            puts "Trovato account #{entry[:dn][0]}"
            user.update(sam: entry[:samaccountname][0])
          else
            puts "NON TROVATO #{user.inspect}"
          end
        end
        p user
        gets
      end
    end
  end
end

# <Net::LDAP::Entry:0x00007f3c3e6578c8 @myhash={:dn=>["CN=Pietro Donatini,OU=Sistemi,OU=Utenti-Adm,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it"], :objectclass=>["top", "person", "organizationalPerson", "user"], :cn=>["Pietro Donatini"], :sn=>["Donatini"], :description=>["Not in cloud sync - adminDescriptopn User_nosync in data 20240408"], :givenname=>["Pietro"], :distinguishedname=>["CN=Pietro Donatini,OU=Sistemi,OU=Utenti-Adm,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it"], :instancetype=>["4"], :whencreated=>["20240408092801.0Z"], :whenchanged=>["20240418094532.0Z"], :displayname=>["Pietro Donatini"], :usncreated=>["882230488"], :memberof=>["CN=amm.sistemi,OU=Sistemi,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it"], :usnchanged=>["891283563"], :admindescription=>["User_nosync"], :protocolsettings=>["RemotePowerShell§0"], :name=>["Pietro Donatini"], :objectguid=>["\xDF\xC40\xD5\x9A\xE3#C\x9F)\x8FO\x13K\x95@"], :useraccountcontrol=>["512"], :badpwdcount=>["0"], :codepage=>["0"], :countrycode=>["0"], :badpasswordtime=>["133579859292973371"], :lastlogon=>["133579859400199247"], :pwdlastset=>["133570430660922022"], :primarygroupid=>["513"], :objectsid=>["\x01\x05\x00\x00\x00\x00\x00\x05\x15\x00\x00\x00\x12\xDF\xE2\x80\xDFL\xD1YM\xC4:\xB9\x05\x81\x10\x00"], :admincount=>["1"], :accountexpires=>["9223372036854775807"], :logoncount=>["11"], :samaccountname=>["donatini.adm"], :samaccounttype=>["805306368"], :userprincipalname=>["donatini.adm@personale.dir.unibo.it"], :objectcategory=>["CN=Person,CN=Schema,CN=Configuration,DC=dir,DC=unibo,DC=it"], :dscorepropagationdata=>["20240410103304.0Z", "20240408094642.0Z", "16010101000000.0Z"], :lastlogontimestamp=>["133579071147782815"]}>
