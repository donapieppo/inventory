class ApplicationController < DmUniboCommon::ApplicationController
  include DmUniboCommon::Controllers::Helpers

  before_action :set_current_user,
    :update_authorization,
    :force_sso_user,
    :set_current_organization,
    :log_current_user,
    :after_current_user_and_organization,
    :set_locale

  def set_current_organization
    @_current_organization = Organization.first
  end

  def set_locale
    I18n.locale = :it
  end
end
