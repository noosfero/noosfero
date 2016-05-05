class RelevantContentPlugin::RelevantContentBlock < Block
  def self.description
    _('Relevant content')
  end

  def default_title
    _('Relevant content')
  end

  def help
    _('This block lists the most popular content.')
  end

  settings_items :limit,                :type => :integer, :default => 5
  settings_items :show_most_read,       :type => :boolean, :default => 1
  settings_items :show_most_commented,  :type => :boolean, :default => 1
  settings_items :show_most_liked,      :type => :boolean, :default => 1
  settings_items :show_most_disliked,   :type => :boolean, :default => 0
  settings_items :show_most_voted,      :type => :boolean, :default => 1

  attr_accessible :limit, :show_most_voted, :show_most_disliked, :show_most_liked, :show_most_commented, :show_most_read

  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def content(args={})

    content = block_title(title, subtitle)

    if self.show_most_read
      docs = Article.most_accessed(owner, self.limit)
      content += subcontent(docs, _("Most read articles"), "mread") unless docs.blank?
    end

    if self.show_most_commented
      docs = Article.most_commented_relevant_content(owner, self.limit)
      content += subcontent(docs, _("Most commented articles"), "mcommented") unless docs.blank?
    end

    if owner.kind_of?(Environment)
      env = owner
    else
      env =  owner.environment
    end

    if env.plugin_enabled?('VotePlugin')
      if self.show_most_liked
        docs = Article.more_positive_votes(owner, self.limit)
        content += subcontent(docs, _("Most liked articles"), "mliked") unless docs.blank?
      end
      if self.show_most_disliked
        docs = Article.more_negative_votes(owner, self.limit)
        content += subcontent(docs, _("Most disliked articles"), "mdisliked") unless docs.blank?
      end

      if self.show_most_voted
        docs = Article.most_voted(owner, self.limit)
        content += subcontent(docs, _("Most voted articles"), "mvoted") unless docs.blank?
      end
    end
    return content.html_safe
  end

  def timeout
    4.hours
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end

  protected

  def subcontent(docs, title, html_class)
    subcontent = safe_join([
      content_tag(:span, title, class: "title #{html_class}"),
      content_tag(:ul, safe_join(docs.map {|item| content_tag('li', link_to(h(item.title), item.url))}, "\n"))
    ], "\n")
    content_tag(:div, subcontent, :class=>"block #{html_class}")
  end

end
