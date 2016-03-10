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

  scope :expired, -> {
    where '(fetched_at is NULL) OR (fetched_at < ?)', Time.now - FeedUpdater.update_interval
  }

  before_create do |block|
    block.limit = 5
    block.feed_items = []
  end

  def self.description
    _('Feed reader')
  end

  def self.pretty_name
    _('Feed Reader')
  end

  def help
    _('This block can be used to list the latest new from any site you want. You just need to inform the address of a RSS feed.')
  end

  def default_title
    self.feed_title.nil? ? _('Feed Reader') : self.feed_title
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

end
