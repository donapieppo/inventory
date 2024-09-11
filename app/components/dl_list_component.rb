# frozen_string_literal: true

class DlListComponent < ViewComponent::Base
  def initialize(record, list)
    @record = record
    @list = list
  end
end
