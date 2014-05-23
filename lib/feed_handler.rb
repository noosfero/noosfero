require 'feedparser'
require 'open-uri'

# This class is responsible for processing feeds and pass the items to the
# respective container.
#
# The <tt>max_errors</tt> attribute controls how many times it will retry in
# case of failure. If a feed fails for <tt>max_errors+1</tt> times, it will be
# disabled and the last error message will be recorder in the container.
# The default value is *6*, if you need to change it you can do that in your
# config/local.rb file like this:
#
#   FeedHandler.max_errors = 10
#
# For the update interval, see FeedUpdater.
class FeedHandler

  # The maximum number
  cattr_accessor :max_errors
  cattr_accessor :disabled_period

  self.max_errors = 6
  self.disabled_period = 1.week

  def parse(content)
    raise FeedHandler::ParseError, "Content is nil" if content.nil?
    begin
      return FeedParser::Feed::new(content)
    rescue Exception => ex
      raise FeedHandler::ParseError, "Invalid feed format."
    end
  end

  def fetch(address)
    begin
      content = ""
      block = lambda { |s| content = s.read }
      content =
        if Rails.env == 'test' && File.exists?(address)
          File.read(address)
        else
          if !valid_url?(address)
            raise InvalidUrl.new("\"%s\" is not a valid URL" % address)
          end
          open(address, "User-Agent" => "Noosfero/#{Noosfero::VERSION}", &block)
        end
      return content
    rescue Exception => ex
      raise FeedHandler::FetchError, ex.message
    end
  end

  def process(container)
    begin
      container.class.transaction do
        if container.update_errors > FeedHandler.max_errors && container.fetched_at < (Time.now - FeedHandler.disabled_period)
          container.enabled = true
          container.update_errors = 0
          container.save
        end
        next unless container.enabled
        actually_process_container(container)
        container.update_errors = 0
        container.finish_fetch
      end
    rescue Exception => exception
      Rails.logger.warn("Unknown error from %s ID %d\n%s" % [container.class.name, container.id, exception.to_s])
      Rails.logger.warn("Backtrace:\n%s" % exception.backtrace.join("\n"))
      container.reload
      container.update_errors += 1
      container.error_message = exception.to_s
      if container.update_errors > FeedHandler.max_errors
        container.fetched_at = Time.now
        container.enabled = false
      end
      begin
        container.finish_fetch
      rescue Exception => finish_fetch_exception
        Rails.logger.warn("Unable to finish fetch from %s ID %d\n%s" % [container.class.name, container.id, finish_fetch_exception.to_s])
        Rails.logger.warn("Backtrace:\n%s" % finish_fetch_exception.backtrace.join("\n"))
      end
    end
  end

  class InvalidUrl < Exception; end
  class ParseError < Exception; end
  class FetchError < Exception; end

  protected

  def actually_process_container(container)
    container.clear
    content = fetch(container.address)
    container.fetched_at = Time.now
    parsed_feed = parse(content)
    container.feed_title = parsed_feed.title
    parsed_feed.items[0..container.limit-1].reverse.each do |item|
      container.add_item(item.title, item.link, item.date, item.content)
    end
  end

  def valid_url?(url)
    url =~ URI.regexp('http') || url =~ URI.regexp('https')
  end

end
