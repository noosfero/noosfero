module FolderHelper

  include ArticleHelper

  def list_contents(configure={})
    configure[:recursive] ||= false
    configure[:list_type] ||= :folder
    contents = configure[:contents]
    contents = contents.order('name ASC') unless contents.is_a? Array
    contents = contents.paginate per_page: 30, page: params[:npage]
    configure[:contents] = contents
    if contents.present?
      render :file => 'shared/content_list', :locals => configure
    else
      content_tag('em', _('(empty folder)'))
    end
  end

  def available_articles(articles, user)
    articles.select {|article| article.display_to?(user)}
  end

  def display_content_icon(content_item)
    content = FilePresenter.for content_item
    content_link = if content.image?
         link_to(
           image_tag(icon_for_article(content, :bigicon)),
           content.url.merge(:view => true)
         )
       else
         link_to('',
          content.url.merge(:view => true),
          :class => icon_for_article(content, :bigicon)
         )
       end
  end

  def icon_for_article(article, size = 'icon')
    article = FilePresenter.for article
    if article.respond_to?(:sized_icon)
      article.sized_icon(size)
    else
      icon = article.respond_to?(:icon_name) ?
              article.icon_name :
              article.class.icon_name(article)
      klasses = "#{size} " + [icon].flatten.map{|name| "#{size}-"+name}.join(' ')
      if article.kind_of?(UploadedFile) || article.kind_of?(FilePresenter)
        klasses += " #{size}-upload-file"
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
