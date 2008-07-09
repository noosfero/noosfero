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
    _('The tag is created when you add some one to your article. <p/>
       Try to add some tags to some articles and see your tag cloud to grow.')
  end

  def content
    tags = owner.tags
    return '' if tags.empty?

    block_title(title) +
    "\n<div class='tag_cloud'>\n"+
    tag_cloud( owner.tags, :id,
               owner.generate_url(:controller => 'profile', :action => 'tag'),
               :max_size => 16, :min_size => 9 ) +
    "\n</div><!-- end class='tag_cloud' -->\n";
  end

end
