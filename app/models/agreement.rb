class Agreement < ApplicationRecord
  has_and_belongs_to_many :projects
  # has_and_belongs_to_many :nodes

  has_many :important_dates, as: :datable

  validates :name, uniqueness: true

  def to_s
    name
  end

  def to_s_long
    "#{name} dal #{I18n.l start_date} al #{I18n.l end_date} (#{typology_name.upcase} con #{party})"
  end

  def typology_name
    if external
      "convenzione"
    else
      "accordo"
    end
  end

  def state
    now = Date.today
    if now < start_date
      :unstarted
    elsif now < end_date - 30.days
      :active
    elsif now < end_date
      :nearend
    else
      :ended
    end
  end
end
