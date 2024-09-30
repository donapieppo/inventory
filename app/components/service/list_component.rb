# frozen_string_literal: true

class Service::ListComponent < ViewComponent::Base
  def initialize(services)
    @services = services.inject(Hash.new { |h, k| h[k] = [] }) { |acc, s| acc[s.software] << s.port; acc }
  end
end
