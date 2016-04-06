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
      if !docs.blank?
        subcontent = ""
        subcontent += content_tag(:span, _("Most read articles"), :class=>"title mread") + "\n"
        subcontent += content_tag(:ul, docs.map {|item| content_tag('li', link_to(h(item.title), item.url))}.join("\n"))
        content += content_tag(:div, subcontent, :class=>"block mread") + "\n"
      end
    end

    if self.show_most_commented
      docs = Article.most_commented_relevant_content(owner, self.limit)
      if !docs.blank?
        subcontent = ""
        subcontent += content_tag(:span, _("Most commented articles"), :class=>"title mcommented") + "\n"
        subcontent += content_tag(:ul, docs.map {|item| content_tag('li', link_to(h(item.title), item.url))}.join("\n"))
        content += content_tag(:div, subcontent, :class=>"block mcommented") + "\n"
      end
    end

    if owner.kind_of?(Environment)
      env = owner
    else
      env =  owner.environment
    end

    if env.plugin_enabled?('VotePlugin')
      if self.show_most_liked
        docs = Article.more_positive_votes(owner, self.limit)
        if !docs.blank?
          subcontent = ""
          subcontent += content_tag(:span, _("Most liked articles"), :class=>"title mliked") + "\n"
          subcontent += content_tag(:ul, docs.map {|item| content_tag('li', link_to(h(item.title), item.url))}.join("\n"))
          content += content_tag(:div, subcontent, :class=>"block mliked") + "\n"
        end
      end
      if self.show_most_disliked
        docs = Article.more_negative_votes(owner, self.limit)
        if !docs.blank?
          subcontent = ""
          subcontent += content_tag(:span, _("Most disliked articles"), :class=>"title mdisliked") + "\n"
          subcontent += content_tag(:ul, docs.map {|item| content_tag('li', link_to(h(item.title), item.url))}.join("\n"))
          content += content_tag(:div, subcontent, :class=>"block mdisliked") + "\n"
        end
      end

      if self.show_most_voted
        docs = Article.most_voted(owner, self.limit)
        if !docs.blank?
          subcontent = ""
          subcontent += content_tag(:span, _("Most voted articles"), :class=>"title mvoted") + "\n"
          subcontent += content_tag(:ul, docs.map {|item| content_tag('li', link_to(h(item.title), item.url))}.join("\n"))
          content += content_tag(:div, subcontent, :class=>"block mvoted") + "\n"
        end
      end
    end
    return content
  end

  def timeout
    4.hours
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end

end
