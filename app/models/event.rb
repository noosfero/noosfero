class Event < Article

  acts_as_having_settings :field => :body

  settings_items :description, :type => :string
  settings_items :link, :type => :string
  settings_items :address, :type => :string

  xss_terminate :only => [ :description ], :with => 'white_list'

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

  def self.by_month(year = nil, month = nil)
    self.find(:all, :conditions => { :start_date => date_range(year, month) })
  end

  def self.date_range(year, month)
    if year.nil? || month.nil?
      today = Date.today
      year = today.year
      month = today.month
    else
      year = year.to_i
      month = month.to_i
    end

    first_day = Date.new(year, month, 1)
    last_day = Date.new(year, month, 1) + 1.month - 1.day

    first_day..last_day
  end

  def date_range
    start_date..(end_date||start_date)
  end

  # FIXME this shouldn't be needed
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include DatesHelper

  def to_html

    result = ''
    html = Builder::XmlMarkup.new(:target => result)

    html.div {
      html.ul {
        html.li {
          html.strong _('URL:')
          html.a(self.link || "", 'href' => self.link || "")
        }
        html.li {
          html.strong _('Address:')
          html.text! self.address || ""
        }
        html.li {
          html.strong _('When:')
          html.text! show_period(start_date, end_date)
        }
      }

      html.div '_____XXXX_DESCRIPTION_GOES_HERE_XXXX_____'
    }

    result.sub('_____XXXX_DESCRIPTION_GOES_HERE_XXXX_____', self.description)
  end

  def link=(value)
    self.body[:link] = maybe_add_http(value)
  end

  def link
    maybe_add_http(self.body[:link])
  end

  protected

  def maybe_add_http(value)
    if value =~ /https?:\/\//
      value
    else
      'http://' + value
    end
  end

end
