class Event < Article

  acts_as_having_settings :field => :body

  settings_items :description, :type => :string
  settings_items :link, :type => :string
  settings_items :address, :type => :string

  validates_presence_of :title, :start_date

  validates_each :start_date do |event,field,value|
    if event.end_date && event.start_date && event.start_date > event.end_date
      event.errors.add(:start_date, _('%{fn} cannot come before end date.'))
    end
  end

  def self.description
    _('A calendar event')
  end

  def self.short_description
    _('Event')
  end

  def icon_name
    'event'
  end

end
