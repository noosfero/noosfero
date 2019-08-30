module ForumHelper
  include ActionView::Helpers::DateHelper

  def cms_label_for_new_children
    _("New discussion topic")
  end

  def cms_label_for_edit
    _("Configure forum")
  end

  def list_forum_posts(articles)
    pagination = pagination_links(articles,
                                  param_name: "npage")
    content = [content_tag("tr",
                           content_tag("th", _("Discussion topic")) +
                           content_tag("th", _("Posts")) +
                           content_tag("th", _("Last post")))]
    artic_len = articles.length
    articles.each_with_index { |art, i|
      css_add = ["position-" + (i + 1).to_s()]
      position = (i % 2 == 0) ? "odd-post" : "even-post"
      css_add << "first" if i == 0
      css_add << "last"  if i == (artic_len - 1)
      css_add << "private" if art.access.eql? Entitlement::Levels.levels[:self]
      css_add << position
      content << content_tag("tr",
                             content_tag("td", topic_title(art), class: "forum-post-title") +
                             content_tag("td", link_to(art.comments.count, art.url.merge(anchor: "comments_list")), class: "forum-post-answers") +
                             content_tag("td", last_topic_update(art).html_safe, class: "forum-post-last-answer"),
                             class: "forum-post " + css_add.join(" "),
                             id: "post-#{art.id}")
    }
    content_tag("table", safe_join(content, "")) + (pagination || "").html_safe
  end

  def topic_title(article)
    topic_link = link_to(article.title, article.url)
    if article.access == Entitlement::Levels.levels[:self]
      content_tag(:span, "", class: "ui-icon ui-icon-locked", title: ("This is a private content")) +
        topic_link
    else
      topic_link
    end
  end

  def last_topic_update(article)
    info = article.info_from_last_update
    if info[:author_url]
      (time_ago_in_words(info[:date]) + " " + _("by") + " " + link_to(info[:author_name], info[:author_url])).html_safe
    else
      time_ago_in_words(info[:date]) + " " + _("by") + " " + info[:author_name]
    end
  end
end
