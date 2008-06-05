class Event < Article

  def self.description
    _('A calendar event')
  end

  def self.short_description
    _('Event')
  end

  acts_as_having_settings :field => :body

  settings_items :description, :type => :string
  settings_items :link, :type => :string

  settings_items :start_date, :type => :date
  settings_items :end_date, :type => :date

  validates_presence_of :title, :start_date
end
