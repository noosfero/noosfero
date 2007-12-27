class RssFeed < Article

  # store setting in body
  serialize Hash, :body

  def body
    self[:body] ||= {}
  end
  alias :settings :body

  def limit
    settings[:limit]
  end
  def limit=(value)
    settings[:limit] = value
  end

  def include
    settings[:include]
  end
  def include=(value)
    settings[:include] = value
  end

  def feed_item_description
    settings[:feed_item_description]
  end
  def feed_item_description=(value)
    settings[:feed_item_description] = value
  end

  # TODO
  def to_html
  end

  # RSS feeds have type =text/xml=.
  def mime_type
    'text/xml'
  end

  # FIXME feed real data into the RSS feed
  def data
    articles =
      if (self.include == :parent_and_children) && self.parent
        self.parent.map_traversal
      else
        profile.recent_documents(self.limit || 10)
      end


    result = ""
    xml = Builder::XmlMarkup.new(:target => result)

    xml.instruct! :xml, :version=>"1.0" 
    xml.rss(:version=>"2.0") do
      xml.channel do
        xml.title(_("%s's RSS feed") % (self.profile.name))
        xml.link("http://www.yourDomain.com")
        xml.description('Description here')
        xml.language("pt_BR")
        for article in articles
          unless self == article
            xml.item do
              xml.title(article.name)
              if self.feed_item_description == :body
                xml.description(article.body)
              else
                xml.description(article.abstract)
              end
              # rfc822
              xml.pubDate(article.created_on.rfc2822)
              xml.link("http://www.yourDomain.com/linkToYourPost")
              xml.guid("http://www.yourDomain.com/linkToYourPost")
            end
          end
        end
      end
    end

    result
  end

  def self.short_description
    _('RSS Feed')
  end

  def self.description
    _('Provides a news feed of your more recent articles.')
  end

end
