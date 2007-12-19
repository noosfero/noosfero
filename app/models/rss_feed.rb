class RssFeed < Article

  # store setting in body
  serialize Hash, :body

  # TODO
  def to_html
  end

  # RSS feeds have type =text/xml=.
  def mime_type
    'text/xml'
  end

  # FIXME - feed real data into the RSS feed
  def data
    result = ""
    xml = Builder::XmlMarkup.new(:target => result)

    xml.instruct! :xml, :version=>"1.0" 
    xml.rss(:version=>"2.0") do
      xml.channel do
        xml.title(_("%s's RSS feed") % (self.profile.name))
        xml.link("http://www.yourDomain.com")
        xml.description('Description here')
        xml.language("pt_BR")
        for article in profile.recent_documents(10)
          xml.item do
            xml.title(article.name)
            xml.description(article.abstract)
            # rfc822
            xml.pubDate(article.created_on.rfc2822)
            xml.link("http://www.yourDomain.com/linkToYourPost")
            xml.guid("http://www.yourDomain.com/linkToYourPost")
          end
        end
      end
    end

    result
  end

end
