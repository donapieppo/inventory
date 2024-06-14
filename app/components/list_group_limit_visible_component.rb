# frozen_string_literal: true

class ListGroupLimitVisibleComponent < ViewComponent::Base
  def initialize(list, placeholder: "", method: :name)
    @list = list
    @placeholder = placeholder
    @method = method
  end
end
