class FeedReaderBlock < Block

  attr_accessible :address, :update_errors

  def initialize(attributes = nil, options = {})
    data = attributes || {}
    super(data)
    self.enabled= !data[:address].blank?
  end

  include DatesHelper

  settings_items :address, :type => :string
  alias :orig_set_address :address=
  def address=(new_address)
    old_address = address
    orig_set_address(new_address)
    self.enabled = (new_address && new_address != old_address) || (new_address && self.enabled) || false
    self.fetched_at = nil
  end

  settings_items :limit, :type => :integer

  settings_items :feed_title, :type => :string
  settings_items :feed_items, :type => :array

  settings_items :update_errors, :type => :integer, :default => 0
  settings_items :error_message, :type => :string

  scope :expired, lambda {
    { :conditions => [ '(fetched_at is NULL) OR (fetched_at < ?)', Time.now - FeedUpdater.update_interval] }
  }

  before_create do |block|
    block.limit = 5
    block.feed_items = []
  end

  def self.description
    _('Feed reader')
  end

  def help
    _('This block can be used to list the latest new from any site you want. You just need to inform the address of a RSS feed.')
  end

  def default_title
    self.feed_title.nil? ? _('Feed Reader') : self.feed_title
  end

  def formatted_feed_content
    if error_message.blank?
      "<ul>\n".html_safe +
      self.feed_items[0..(limit-1)].map{ |item| "<li><a href='#{item[:link]}'>#{item[:title]}</a></li>" }.join("\n").html_safe +
      "</ul>".html_safe
    else
      "<p>#{error_message}</p>".html_safe
    end
  end

  def footer
    if self.fetched_at.nil? or self.feed_items.empty?
      _('Feed content was not loaded yet')
    else
      _("Updated: %s") % show_date(self.fetched_at)
    end
  end

  def add_item(title, link, date, content)
    self.feed_items.unshift( {:title => title, :link => link})
  end

  def clear
    self.feed_items = []
    self.feed_title = nil
    self.error_message = nil
  end

  def finish_fetch
    self.fetched_at = Time.now
    self.save!
  end

  def content(args={})
    block_title(title) + formatted_feed_content
  end

end
