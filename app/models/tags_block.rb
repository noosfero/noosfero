class TagsBlock < Block

  include TagsHelper
  include BlockHelper
  include ActionController::UrlWriter

  def self.description
    _('Block listing content count by tag')
  end

  def default_title
    _('tags')
  end

  def help
    _("Tags are created when you add some of them one to your contents. <p/>
       Try to add some tags to some articles and you'l see your tag cloud growing.")
  end

  def content
    tags = owner.article_tags
    return '' if tags.empty?

    block_title(title) +
    "\n<div class='tag_cloud'>\n"+
    tag_cloud( tags, :id,
               owner.public_profile_url.merge(:controller => 'profile', :action => 'tag'),
               :max_size => 16, :min_size => 9 ) +
    "\n</div><!-- end class='tag_cloud' -->\n";
  end

  def timeout
    15.minutes
  end

end
