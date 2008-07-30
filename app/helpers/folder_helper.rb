module FolderHelper

  def list_articles(articles, recursive = false)
    content_tag(
      'table',
      content_tag('tr', content_tag('th', _('Title')) + content_tag('th', _('Last update'))) +
      articles.map {|item| display_article_in_listing(item, recursive, 0)}.join('')
    )
  end

  def display_article_in_listing(article, recursive = false, level = 0)
    result = content_tag(
      'tr',
      content_tag('td', link_to(('&nbsp;' * (level * 4) ) + image_tag(icon_for_article(article)) + article.name, article.url))+
      content_tag('td', show_date(article.updated_at), :class => 'last-update'),
      :class => 'sitemap-item'
    )
    if recursive
      result + article.children.map {|item| display_article_in_listing(item, recursive, level + 1) }.join('')
    else
      result
    end
  end

  def icon_for_article(article)
    icon = article.icon_name
    if (icon =~ /\//)
      icon
    else
      if File.exists?(File.join(RAILS_ROOT, 'public', 'images', 'icons-mime', "#{icon}.png"))
        "icons-mime/#{icon}.png"
      else
        "icons-mime/unknown.png"
      end
    end
  end

end
