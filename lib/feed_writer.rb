class FeedWriter

  include Rails.application.routes.url_helpers

  def write(articles, options = {})
    result = ""
    xml = Builder::XmlMarkup.new(:target => result)

    xml.instruct! :xml, :version=>"1.0"
    xml.rss(:version=>"2.0") do
      xml.channel do
        xml.title(options[:title] || _('Feed'))
        if options[:link]
          xml.link(options[:link])
        end
        if options[:description]
          xml.description(options[:description])
        end
        for article in articles
          xml.item do
            xml.title(article.name)
            xml.description(article.to_html)
            if article.created_at
              # rfc822
              xml.pubDate(article.created_at.rfc2822)
            end
            # link to article
            xml.link(url_for(article.url))
            xml.guid(url_for(article.url))
          end
        end
      end
    end

    result
  end
end
