require 'noosfero/translatable_content'
require 'builder'

class Event < Article

  attr_accessible :start_date, :end_date, :link, :address

  def self.type_name
    _('Event')
  end

  settings_items :address, :type => :string

  def link=(value)
    self.setting[:link] = maybe_add_http(value)
  end

  def link
    maybe_add_http(self.setting[:link])
  end

  xss_terminate :only => [ :name, :body, :link, :address ], :with => 'white_list', :on => 'validation'

  def initialize(*args)
    super(*args)
    self.start_date ||= Date.today
  end

  validates_presence_of :title, :start_date

  validates_each :start_date do |event,field,value|
    if event.end_date && event.start_date && event.start_date > event.end_date
      event.errors.add(:start_date, _('{fn} cannot come before end date.').fix_i18n)
    end
  end

  scope :by_day, lambda { |date|
    { :conditions => ['start_date = :date AND end_date IS NULL OR (start_date <= :date AND end_date >= :date)', {:date => date}],
      :order => 'start_date ASC'
    }
  }

  scope :next_events_from_month, lambda { |date|
    date_temp = date.strftime("%Y-%m-%d")
    { :conditions => ["start_date >= ?","#{date_temp}"],
      :order => 'start_date ASC'
    }
  }

  scope :by_month, lambda { |date|
    { :conditions => ["EXTRACT(YEAR FROM start_date) = ? AND EXTRACT(MONTH FROM start_date) = ?",date.year,date.month],
      :order => 'start_date ASC'
    }
  }

  include WhiteListFilter
  filter_iframes :body, :link, :address
  def iframe_whitelist
    profile && profile.environment && profile.environment.trusted_sites_for_iframe
  end

  def self.description
    _('A calendar event.')
  end

  def self.short_description
    _('Event')
  end

  def self.icon_name(article = nil)
    'event'
  end

  scope :by_range, lambda { |range| {
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

  def first_paragraph
    paragraphs = Nokogiri::HTML.fragment(self.body).css('p')
    paragraphs.empty? ? '' : paragraphs.first.to_html
  end

  def to_html(options = {})
    event = self
    format = options[:format]

    proc do
      render :file => 'content_viewer/event_page', :locals => { :event => event,
        :format => format }
    end
  end

  def duration
    ((self.end_date || self.start_date) - self.start_date).to_i
  end

  alias_method :article_lead, :lead
  def lead
    self.class.action_view.render 'content_viewer/event_lead', event: self
  end

  def event?
    true
  end

  def tiny_mce?
    true
  end

  def notifiable?
    true
  end

  include Noosfero::TranslatableContent
  include MaybeAddHttp

end
