class ImportantDate::ListComponent < ViewComponent::Base
  def initialize(dates, editable: false, with_new: false, parent: nil)
    @dates = dates
    @editable = editable
    @with_new = with_new
    @parent = parent
  end
end
