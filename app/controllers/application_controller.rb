class ApplicationController < DmUniboCommon::ApplicationController
  before_action :set_current_user,
    :update_authorization,
    :set_current_organization,
    :after_current_user_and_organization,
    :log_current_user,
    :set_locale

  def set_locale
    I18n.locale = :it
  end
  after_action :skip_authorization
end
