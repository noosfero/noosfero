require 'short_filename'

module FolderHelper

  include ShortFilename
  include ArticleHelper

  def list_contents(configure={})
    configure[:recursive] ||= false
    configure[:list_type] ||= :folder
    if !configure[:contents].blank?
      configure[:contents] = configure[:contents].paginate(
        :order => "updated_at DESC",
        :per_page => 10,
        :page => params[:npage]
      )

      render :file => 'shared/content_list', :locals => configure
    else
      content_tag('em', _('(empty folder)'))
    end
  end

  def available_articles(articles, user)
    articles.select {|article| article.display_to?(user)}
  end

  def display_content_in_listing(configure={})
    recursive = configure[:recursive] || false
    list_type = configure[:list_type] || :folder
    level = configure[:level] || 0
    content = FilePresenter.for configure[:content]
    content_link = if content.image?
         link_to('&nbsp;' * (level * 4) +
           image_tag(icon_for_article(content)) + short_filename(content.name),
           content.url.merge(:view => true)
         )
       else
         link_to('&nbsp;' * (level * 4) +
           short_filename(content.name),
           content.url.merge(:view => true), :class => icon_for_article(content)
         )
       end
    result = content_tag(
      'tr',
      content_tag('td', content_link ) +
      content_tag('td', show_date(content.updated_at), :class => 'last-update'),
      :class => "#{list_type}-item"
    )
    if recursive
      result + content.children.map {|item|
        display_content_in_listing :content=>item, :recursive=>recursive,
                                   :list_type=>list_type, :level=>level+1
      }.join("\n")
    else
      result
    end
  end

  def icon_for_article(article)
    article = FilePresenter.for article
    icon = article.respond_to?(:icon_name) ?
             article.icon_name :
             article.class.icon_name(article)
    if (icon =~ /\//)
      icon
    else
      klasses = 'icon ' + [icon].flatten.map{|name| 'icon-'+name}.join(' ')
      if article.kind_of?(UploadedFile) || article.kind_of?(FilePresenter)
        klasses += ' icon-upload-file'
      end
      klasses
    end
  end

  def icon_for_new_article(klass)
    "icon-new icon-new%s" % klass.icon_name
  end

  def custom_options_for_article(article,tokenized_children)
    @article = article

    visibility_options(article,tokenized_children) +
    content_tag('div',
      hidden_field_tag('article[accept_comments]', 0)
    )
  end

  def cms_label_for_new_children
    _('New article')
  end

  def cms_label_for_edit
    _('Edit folder')
  end

end
