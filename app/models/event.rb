class Event < Article

  settings_items :address, :type => :string

  def link=(value)
    self.setting[:link] = maybe_add_http(value)
  end

  def link
    maybe_add_http(self.setting[:link])
  end

  xss_terminate :only => [ :link ], :on => 'validation'
  xss_terminate :only => [ :body, :link, :address ], :with => 'white_list', :on => 'validation'

  def initialize(*args)
    super(*args)
    self.start_date ||= Date.today
  end

  validates_presence_of :title, :start_date

  validates_each :start_date do |event,field,value|
    if event.end_date && event.start_date && event.start_date > event.end_date
      event.errors.add(:start_date, _('%{fn} cannot come before end date.'))
    end
  end

  named_scope :by_day, lambda { |date|
    {:conditions => ['start_date = :date AND end_date IS NULL OR (start_date <= :date AND end_date >= :date)', {:date => date}]}
  }

  include WhiteListFilter
  filter_iframes :body, :link, :address, :whitelist => lambda { profile && profile.environment && profile.environment.trusted_sites_for_iframe }

  def self.description
    _('A calendar event')
  end

  def self.short_description
    _('Event')
  end

  def self.icon_name(article = nil)
    'event'
  end

  named_scope :by_range, lambda { |range| {
    :conditions => [
      'start_date BETWEEN :start_day AND :end_day OR end_date BETWEEN :start_day AND :end_day',
      { :start_day => range.first, :end_day => range.last }
    ]
  }}

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
    last_day = first_day + 1.month - 1.day

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

  def to_html(options = {})

    result = ''
    html = Builder::XmlMarkup.new(:target => result)

    html.div(:class => 'event-info' ) {

      html.ul(:class => 'event-data' ) {
        html.li(:class => 'event-dates' ) {
          html.span _('When:')
          html.text! show_period(start_date, end_date)
        }
        html.li {
          html.span _('URL:')
          html.a(self.link || "", 'href' => self.link || "")
        }
        html.li {
          html.span _('Address:')
          html.text! self.address || ""
        }
      }

      if self.body
        html.div('_____XXXX_DESCRIPTION_GOES_HERE_XXXX_____', :class => 'event-description') 
      end
    }

    if self.body
      result.sub!('_____XXXX_DESCRIPTION_GOES_HERE_XXXX_____', self.body)
    end

    result
  end

  def event?
    true
  end

  def tiny_mce?
    true
  end

  include Noosfero::TranslatableContent
  include MaybeAddHttp

end
