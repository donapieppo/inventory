# frozen_string_literal: true

class ListGroupLimitVisibleComponent < ViewComponent::Base
  def initialize(placeholder: "", display: "block")
    @placeholder = placeholder
    @display = display
  end
end
