class FeedReaderBlock < Block

  include DatesHelper

  settings_items :address, :type => :string
  settings_items :limit, :type => :integer
  settings_items :fetched_at, :type => :date

  settings_items :feed_title, :type => :string
  settings_items :feed_items, :type => :array

  before_create do |block|
    block.limit = 5
    block.feed_items = []
  end

  def self.description
    _('List the latest N posts from a given RSS feed.')
  end

  def help
    _('This block can be used to create a list of latest N posts from a given RSS feed. You should only enter the RSS feed address.')
  end

  def default_title
    self.feed_title.nil? ? _('Feed Reader') : self.feed_title
  end

  def formatted_feed_content
    if self.fetched_at.nil? or self.feed_items.empty?
      return ("<p class='feed-reader-block-error'>%s</p>" % _('Feed content was not loaded yet'))
    else
      return "<ul class='feed-reader-block-list'>" +
        self.feed_items.map{ |item| "<li><a href='#{item[:link]}' class='feed-reader-block-item'>#{item[:title]}</a></li>" }.join("\n") +
        "</ul>" +
        "<div class='feed-reader-block-fetched-at'>#{_("Updated: %s") % show_date(self.fetched_at)}</div>"
    end
  end

  def add_item(title, link, date, content)
    self.feed_items << {:title => title, :link => link}
  end

  def clean
    self.feed_items = []
    self.feed_title = nil
  end

  def content
    block_title(title) + formatted_feed_content
  end

  def editable?
    true
  end

end
