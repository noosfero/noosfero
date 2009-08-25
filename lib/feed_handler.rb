require 'feedparser'
require 'open-uri'

class FeedHandler

  def parse(content)
    raise FeedHandler::ParseError, "Content is nil" if content.nil?
    begin
      return FeedParser::Feed::new(content)
    rescue Exception => ex
      raise FeedHandler::ParseError, ex.to_s
    end
  end

  def fetch(address)
    begin
      content = ""
      block = lambda { |s| content = s.read }
      content = if is_web_address?(address)
        open( address, "User-Agent" => "Noosfero/#{Noosfero::VERSION}", &block )
      else
        open_uri_original_open(address, &block)
      end
      return content
    rescue Exception => ex
      raise FeedHandler::FetchError, ex.to_s
    end
  end

  def process(container)
    container.class.transaction do
      container.clear
      content = fetch(container.address)
      container.fetched_at = Time.now
      parsed_feed = parse(content)
      container.feed_title = parsed_feed.title
      parsed_feed.items[0..container.limit-1].reverse.each do |item|
        container.add_item(item.title, item.link, item.date, item.content)
      end
      container.finish_fetch
    end
  end

  class ParseError < Exception; end
  class FetchError < Exception; end

  protected

  # extracted from the open implementation in the open-uri library
  def is_web_address?(address)
    address.respond_to?(:open) ||
      address.respond_to?(:to_str) &&
      (%r{\A[A-Za-z][A-Za-z0-9+\-\.]*://} =~ address) &&
      URI.parse(address).respond_to?(:open)
  end

end
