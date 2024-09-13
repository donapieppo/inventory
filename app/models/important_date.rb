class ImportantDate < ApplicationRecord
  belongs_to :datable, polymorphic: true

  validates :date_type, presence: true

  def to_s
    "#{I18n.l date} #{name} #{date_type}"
  end
end
