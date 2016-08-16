module GalleryHelper

  include ArticleHelper

  def extra_options
    content_tag(
        'div',
        check_box(:article, :allow_download) +
        content_tag('label', _('Allow images from this gallery to be downloaded'), :for => 'article_allow_download')
    )
  end

end
