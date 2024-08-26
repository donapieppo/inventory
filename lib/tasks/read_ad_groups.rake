require "net/ldap"
CESIA_BASE = "OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it"

def account?(entry)
  entry[:objectclass].include?("organizationalPerson")
end

def ldap_connect
  Net::LDAP.new(
    host: Rails.configuration.ad_server,
    port: Rails.configuration.ad_server_port,
    auth: {
      method: :simple,
      username: Rails.configuration.ad_username,
      password: Rails.configuration.ad_pwd
    },
    encryption: :simple_tls
  )
end

# get a cn and recursivly gets the members
def extract_members(ldap, cn)
  puts "------- cerco membri di #{cn} --------------"
  members = []
  # amm.sistemi
  filter = Net::LDAP::Filter.eq("cn", cn)
  ldap.search(base: Rails.configuration.ad_treebase, filter: filter) do |entry|
    if account?(entry)
      # CN=Michele Montani,OU=Sistemi,OU=Utenti-Adm,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it
      puts "Trovato account #{entry[:dn][0]}"
      members << entry
    else
      puts "Trovato group #{entry[:dn][0]}"
      entry[:member].each do |m|
        members += extract_members(ldap, m.split(",")[0].split("=")[1])
      end
    end
  end
  members
end

# association AdmUser -> Usre
def fix_adm_users(ldap)
  AdmUser.where(user_id: nil).each do |adm_user|
    u = User.where(
      name: adm_user.name,
      surname: adm_user.surname
    ).first
    if u
      adm_user.update!(user_id: u.id)
    else
      filter = Net::LDAP::Filter.eq("sn", adm_user.surname) & Net::LDAP::Filter.eq("givenname", adm_user.name)
      p adm_user
      ldap.search(base: CESIA_BASE, filter: filter) do |entry|
        p entry[:dn][0]
      end
    end
  end
end

namespace :inventory do
  namespace :puppet do
    desc "Read adm_groups users"
    task read_ad_group_users: :environment do
      ldap = ldap_connect

      # AdGroup.where(name: "Str81009.servizioinformatico.Grp").each do |adg|
      AdGroup.find_each do |adg|
        p adg.name

        members = extract_members(ldap, adg.name)
        members.each do |user|
          upn = user[:userprincipalname][0] or raise "NON TROVO #{user}"
          id_anagrafica_unica = user[:extensionAttribute6]&.first

          puts "member of #{adg.name}: #{upn} : #{id_anagrafica_unica}"

          if id_anagrafica_unica
            # User with id_anagrafica_unica
            u = User.create_with(
              upn: upn,
              email: upn,
              name: user[:givenname][0],
              surname: user[:sn][0],
              sam: user[:samaccountname][0]
            ).find_or_create_by(id: id_anagrafica_unica.to_i)
            begin
              adg.users << u
            rescue ActiveRecord::RecordNotUnique
            end
          elsif (adm_user = AdmUser.where(upn: upn).first)
            if adm_user.user_id
              begin
                adg.users << adm_user.user
              rescue ActiveRecord::RecordNotUnique
              end
            end
          else
            AdmUser.create_with(
              email: upn,
              name: user[:givenname][0],
              surname: user[:sn][0],
              sam: user[:samaccountname][0]
            ).find_or_create_by!(upn: upn)
          end
          # gets
        end
        sleep 1
      end

      fix_adm_users(ldap)
    end
  end
end

namespace :inventory do
  namespace :puppet do
    desc "Join AdmUser to User"
    task join_adm_users: :environment do
      AdmUser.find_each do |adm_user|
        u = User.where(
          name: adm_user.name,
          surname: adm_user.surname
        ).first
        if u
          adm_user.update!(user_id: u.id)

        else
          puts "NON TROVO"
          p adm_user
        end
      end
    end
  end
end

# con idanagrafica

# senza idanagrafica
# <Net::LDAP::Entry:0x00007f3c3e6578c8 @myhash={:dn=>["CN=Pietro Donatini,OU=Sistemi,OU=Utenti-Adm,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it"], :objectclass=>["top", "person", "organizationalPerson", "user"], :cn=>["Pietro Donatini"], :sn=>["Donatini"], :description=>["Not in cloud sync - adminDescriptopn User_nosync in data 20240408"], :givenname=>["Pietro"], :distinguishedname=>["CN=Pietro Donatini,OU=Sistemi,OU=Utenti-Adm,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it"], :instancetype=>["4"], :whencreated=>["20240408092801.0Z"], :whenchanged=>["20240418094532.0Z"], :displayname=>["Pietro Donatini"], :usncreated=>["882230488"], :memberof=>["CN=amm.sistemi,OU=Sistemi,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it"], :usnchanged=>["891283563"], :admindescription=>["User_nosync"], :protocolsettings=>["RemotePowerShell§0"], :name=>["Pietro Donatini"], :objectguid=>["\xDF\xC40\xD5\x9A\xE3#C\x9F)\x8FO\x13K\x95@"], :useraccountcontrol=>["512"], :badpwdcount=>["0"], :codepage=>["0"], :countrycode=>["0"], :badpasswordtime=>["133579859292973371"], :lastlogon=>["133579859400199247"], :pwdlastset=>["133570430660922022"], :primarygroupid=>["513"], :objectsid=>["\x01\x05\x00\x00\x00\x00\x00\x05\x15\x00\x00\x00\x12\xDF\xE2\x80\xDFL\xD1YM\xC4:\xB9\x05\x81\x10\x00"], :admincount=>["1"], :accountexpires=>["9223372036854775807"], :logoncount=>["11"], :samaccountname=>["donatini.adm"], :samaccounttype=>["805306368"], :userprincipalname=>["donatini.adm@personale.dir.unibo.it"], :objectcategory=>["CN=Person,CN=Schema,CN=Configuration,DC=dir,DC=unibo,DC=it"], :dscorepropagationdata=>["20240410103304.0Z", "20240408094642.0Z", "16010101000000.0Z"], :lastlogontimestamp=>["133579071147782815"]}>
#
# #<Net::LDAP::Entry:0x00007f8fc1138d98 @myhash={:dn=>["CN=Mat033845,OU=Str02373,OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it"], :objectclass=>["top", "person", "organizationalPerson", "user"], :cn=>["Mat033845"], :sn=>["Donatini"], :title=>["Area dei funzionari- settore tecnico- informatico"], :description=>["Dott. Pietro Donatini"], :telephonenumber=>["+39 051 2080141"], :givenname=>["Pietro"], :distinguishedname=>["CN=Mat033845,OU=Str02373,OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it"], :instancetype=>["4"], :whencreated=>["20020619112517.0Z"], :whenchanged=>["20240821063355.0Z"], :displayname=>["Pietro Donatini"], :usncreated=>["251733"], :memberof=>["CN=Str01931.Personale.OptBase,CN=Opzioni,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931.Personale.All.GRUPPOPIATTOCESIA.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.Tommasi-CA-CDA2024.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.Vasina-TA-CDA2024.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=BOSediServizioTA.Turchini-BO-CDA2024.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.Turchini-TA-CDA2024.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=BOSediServizioTA.OptBase,CN=Opzioni,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=BOSediServizioTA.CognomeTASedeBO.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Qualifica.04444000,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.Cusimano-TA-Senato2024.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.Frighi-TA-SA2024.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.Alesiani-TA-SA2024.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.Barbino-TA-SA2024.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.campisi-TA-SA2024.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str04588.16727-redazioniweb,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-ScelteFinanzConsMarzo24,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=AmministrazioneCentrale.Personale.GruppoPiattoAMMGEN.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str04589.16728-call_formatoriPTA,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-vpa23valutati,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-stream_unibo,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00726-ListaNuovaDichiarazione,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-ScelteFinanzConsSE,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.CUSBPTA.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-AbilitatiNASUNIBO,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.SNALSPersonaleTA.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01837-recallmodulo1_doppiocorso23,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ListaIDMtest2.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-Recall26072022_Modulo1TA,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-mailBasicAuth,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-O365MFA-Personale,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-PreAccreditanti,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-tecnici.informatici,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-sistemi.cesia,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ListaTASindacatoANIEF.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-Recall25102021privacyTA,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=BOSediServizioTA,OU=StrDsa.Poli,DC=personale,DC=dir,DC=unibo,DC=it", "CN=BOIncardinatiTA,OU=StrDsa.Poli,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Dsa.Vuoto.Divella-TABo-Senato2021.OptIn,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Dsa.Vuoto.Divella-TABo-Senato2021.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Dsa.Vuoto.TURCHINI-TABo-Senato2021.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Dsa.Vuoto.TURCHINI-TABo-Senato2021.OptIn,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.TURCHINI-TA-Senato2021.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.PILEGGI-TA-Senato2021.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.DIVELLA-TA-Senato2021.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.04240.molari-PTA-mr2021.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=MatematicaEditori,OU=Matematica,OU=Dipartimenti,OU=Utenti,OU=Portale,DC=studenti,DC=dir,DC=unibo,DC=it", "CN=Qualifica1224200,OU=Qualifiche,OU=Portale,DC=studenti,DC=dir,DC=unibo,DC=it", "CN=Str01931-O365Lic-AdvancedComm,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str10000-CALMA-AbilitatiPrenotaVaccini,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ListaTAperRSU.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ListaTASindacatoCISL.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ListaTASindacatoUIL.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ListaTASindacatoCGIL.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-formazione-sicurezza-modulo1,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-aggAIRM_BO,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-destinatarisquadre,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-invioComunicazionePEO,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00963.fax.86375.Grp,OU=Str00963,OU=StrDsa.Dip,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00963-picontest,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ConsultaPTAComunicazioni.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str99999.QualificaAggregata.CatD,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931.QualificaAggregata.CatD,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str02108.QualificaAggregata.CatD,OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.STORARI-listaprova.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str80080-AUTCchiusura,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAIR.2000,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAI.3300,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAI.2400,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAI.2000,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAIR.0,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.03300.PROVA-TAtec.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02004.PROVA-TIndeterminato.User,OU=Opzioni.OggettiDismessi,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAI.0,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAIR.3300,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=RuoloAggregato.TAIR.2400,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str10000-RUP-RespProcessiCompl,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-settoreformazione,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00963.siam-is2018.Grp,OU=Str00963,OU=StrDsa.Dip,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00151-utentititulus,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00727-personaleTadipartimenti,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00963-AdmSWT,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str10000-IndagineComEfficace,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Dsa.Personale.SecondoFattoreAttivabile,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str02373.membri,OU=Str02373,OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str02373.Personale.Ou,OU=Str02373,OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str02373.QualificaAggregata.CatD,OU=Str02373,OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.04240.PROVA-personaleTAind-rettore2015.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=str00963-01.adm,OU=Server-Adm,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00963-FS-Didattica.W,OU=Str00963.FS,OU=Str00963-MAT,OU=Dsa.Auto,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.OptBase,CN=Opzioni,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str81380-elezioniCUN2015-pta,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str01931-CMDBuild-Sistemi,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=PwdPolicyStandard,CN=PolicyPwd,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str80080-cmdbuild-CertificatiSSL,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.InfoCuboPTA.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ConvenzioniCuboPTA.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00010.umi.Grp,OU=Str00010,OU=StrDsa.Cessate,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Ruolo.ND,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00010-seminari,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00010-infocdl,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00010-admin,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00010-gemma,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str10-aule-admins,OU=Str10-SSO,OU=Str00963.Dipartimento,OU=Str00963-MAT,OU=Dsa.Auto,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Qualifica.01224300,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Qualifica.01224400,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str81380-elettoratoCUNpersonaleTA,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str10-missioni-amministrazione,OU=Str10-SSO,OU=Str00963.Dipartimento,OU=Str00963-MAT,OU=Dsa.Auto,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str10000-referentiinformatici,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00010-supportoweb,OU=GruppiManuali,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=SVC.CDS.118,OU=CDS,OU=Utenti,OU=SVC,OU=Str80500-DSAW,OU=Dsa.Auto,DC=personale,DC=dir,DC=unibo,DC=it", "CN=PreAccreditanti,OU=PreAccreditamento,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Qualifica.01224200,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Qualifica.01224500,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Qualifica.01224100,CN=Qualifiche,OU=Dsa,DC=personale,DC=dir,DC=unibo,DC=it", "CN=TecniciInformatici,OU=CeSIA,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Cessati.GrpDottorandi,OU=Cessati,DC=personale,DC=dir,DC=unibo,DC=it", "CN=QualificaAggregata.02000.ListaPersonaleTA-RLS.User,OU=Opzioni,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it", "CN=Str00010-8021x,OU=Str00963-MAT,OU=Dsa.Auto,DC=personale,DC=dir,DC=unibo,DC=it", "CN=SSIS-GPO-Tecnici,OU=Servizi-GPO,OU=SSIS,OU=Gestione,DC=personale,DC=dir,DC=unibo,DC=it"], :usnchanged=>["997717926"], :proxyaddresses=>["x500:/o=UNIBO/ou=First Administrative Group/cn=Recipients/cn=pietro.donatini", "smtp:pietro.donatini@liveunibo.mail.onmicrosoft.com", "x500:/o=ExchangeLabs/ou=Exchange Administrative Group (FYDIBOHF23SPDLT)/cn=Recipients/cn=eff2b4cae76c43c8b359348f941862cf-Mat033845", "X500:/o=ExchangeLabs/ou=Exchange Administrative Group (FYDIBOHF23SPDLT)/cn=Recipients/cn=pietro.donatini13716381da", "X400:C=us;A= ;P=UNIBO;O=Exchange;S=Donatini;G=Pietro;", "smtp:donatini@dm.unibo.it", "SMTP:pietro.donatini@unibo.it"], :streetaddress=>["Piazza Porta San Donato, 5"], :targetaddress=>["SMTP:pietro.donatini@liveunibo.mail.onmicrosoft.com"], :extensionattribute1=>["it"], :extensionattribute5=>["member@unibo.it;staff@unibo.it"], :extensionattribute6=>["436108"], :extensionattribute7=>[";114;"], :extensionattribute8=>["16384/1"], :mailnickname=>["pietro.donatini"], :wwwhomepage=>["http://www.dm.unibo.it/~donatini"], :protocolsettings=>["RemotePowerShell§0", "HTTP§1§1§§§§§§", "OWA§1"], :personaltitle=>["Dott."], :name=>["Mat033845"], :objectguid=>["o\xBCP\\\xBB\xD0\x00@\x96\xB9h\xB8v*m\x9A"], :useraccountcontrol=>["512"], :badpwdcount=>["0"], :codepage=>["0"], :countrycode=>["0"], :employeeid=>["33845"], :badpasswordtime=>["133621290390593902"], :lastlogoff=>["0"], :lastlogon=>["133688931956953109"], :pwdlastset=>["133565143545942513"], :primarygroupid=>["513"], :objectsid=>["\x01\x05\x00\x00\x00\x00\x00\x05\x15\x00\x00\x00\x12\xDF\xE2\x80\xDFL\xD1YM\xC4:\xB9\xD6\x04\x00\x00"], :accountexpires=>["0"], :logoncount=>["2280"], :samaccountname=>["pietro.donatini"], :samaccounttype=>["805306368"], :showinaddressbook=>["CN=Default Global Address List,CN=All Global Address Lists,CN=Address Lists Container,CN=UNIBO,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=dir,DC=unibo,DC=it"], :othermailbox=>["pietro.donatini@unibo.it"], :managedobjects=>["CN=str10-robdie,OU=str00963-filopanti,OU=Str00963-MAT,OU=Dsa.Auto,DC=personale,DC=dir,DC=unibo,DC=it"], :legacyexchangedn=>["/o=UNIBO/ou=External (FYDIBOHF25SPDLT)/cn=Recipients/cn=9e30428d610b46f4844c76f17da93a02"], :userprincipalname=>["pietro.donatini@unibo.it"], :objectcategory=>["CN=Person,CN=Schema,CN=Configuration,DC=dir,DC=unibo,DC=it"], :dscorepropagationdata=>["20240603121734.0Z", "20240410103309.0Z", "20240403173550.0Z", "20240209172539.0Z", "16010101000417.0Z"], :lastlogontimestamp=>["133686956344816027"], :"msds-keycredentiallink"=>["B:574:000200001000016C2CD8476C48412DB57498ACF77DAB50200002995D98AC97C3CDB6B5D943AD1247471A70B8CE69D51B9D0FBF89C6D3E45385349F00037B226B7479223A224543222C22637276223A22502D323536222C2278223A22477173706A50736477624841532D694847556563784D387331464E5F665F4E3266434F6E5F4B64766E5245222C2279223A22614E6245784E59544B636F49786456636E4E65566964435041564C67345745686A584153545A30445F3949222C226B6964223A2262437A595232784951533231644A69733933327255413D3D227D01000401010005011000061D139230C35A9149BBF61CB24A81164B0F000701000001000202030000000000000008000800000000000000000800093FA4200F3D7EDC48:CN=Mat033845,OU=Str02373,OU=Str02108,OU=Str01931,OU=Str99999,DC=personale,DC=dir,DC=unibo,DC=it"], :textencodedoraddress=>["X400:C=us;A= ;P=UNIBO;O=Exchange;S=Donatini;G=Pietro;"], :mail=>["pietro.donatini@unibo.it"], :msexchalobjectversion=>["277"], :msexchuseraccountcontrol=>["0"], :msexchmailboxguid=>["r\xC8`\xDC\xD3/WK\xADT\xF0Ad\xDDq\x1C"], :msexchpoliciesincluded=>["99a4fda4-c48e-4cff-9095-28270c75e614", "{26491cfc-9e50-4857-861b-0cb8df22b5d7}"], :msexchmobilemailboxflags=>["1"], :msexchumdtmfmap=>["reversedPhone:141080215093+", "emailAddress:74387636628464", "lastNameFirstName:36628464743876", "firstNameLastName:74387636628464"], :msexchremoterecipienttype=>["4"], :msexchtextmessagingstate=>["302120705", "553648383"], :msexchrecipientdisplaytype=>["-2147483642"], :"msds-externaldirectoryobjectid"=>["User_eba9103e-42fe-4358-99b8-f197c3432fb0"], :msexchrecipienttypedetails=>["2147483648"], :msexchelcmailboxflags=>["16"], :msexchwhenmailboxcreated=>["20101028153814.0Z"], :msexchsaferecipientshash=>["\xA5\xC4\x18\x01\x8D\xEF\xE9\x1C,\xB4\xAE\x1D\xD6\f\xDD4\xA5\xAF\xA39\x88\x94%S\x0E\xE3hb\x89H\x06p\x94 J\x92\xE7w\xD6\x98n0\xEA\x9E\r@g\xBA\xFF\x86\a\xD9\vF\xAE\xDB)\xC3Y\xE5<-x\xEF"], :msexchsafesendershash=>["\xA5\xC4\x18\x01\x8D\xEF\xE9\x1C,\xB4\xAE\x1D\xD6\f\xDD4\xA5\xAF\xA39\x88\x94%S\x0E\xE3hb\x89H\x06p\x94 J\x92\xE7w\xD6\x98n0\xEA\x9E\r@g\xBA\xFF\x86\a\xD9\vF\xAE\xDB)\xC3Y\xE5<-x\xEF"], :msexchversion=>["88218628259840"], :msexchowapolicy=>["CN=Default,CN=OWA Mailbox Policies,CN=UNIBO,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=dir,DC=unibo,DC=it"]}>
