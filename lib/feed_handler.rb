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
      open(address) do |s| content = s.read end
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
      parse = parse(content)
      container.feed_title = parse.title
      parse.items[0..container.limit-1].each do |item|
        container.add_item(item.title, item.link, item.date, item.content)
      end
      container.finish_fetch
    end
  end

  class ParseError < Exception; end
  class FetchError < Exception; end

end
