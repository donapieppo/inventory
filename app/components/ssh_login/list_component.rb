# frozen_string_literal: true

class SshLogin::ListComponent < ViewComponent::Base
  def initialize(ssh_logins, show: :user)
    @ssh_logins = ssh_logins
    @show = show
  end
end
