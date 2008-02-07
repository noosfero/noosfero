class TagsBlock < Block

  include TagsHelper
  include ApplicationHelper

  def self.description
    _('List count of contents by tag')
  end

  def content
    content_tag('h3', _('Tags'), :class => 'block-title') +
    help_textile(
              _('The tag is created when you add some one to your article.
                 Try to add some tags to some articles and see your tag cloud to grow.'),
              _('How tags works here?'), :class => 'help_tags' ) +
    "\n<div class='tag_cloud'>\n"+
    tag_cloud( owner.tags, :id,
               owner.generate_url(:controller => 'profile', :action => 'tag') + '/',
               :max_size => 18, :min_size => 9 ) +
    "\n</div><!-- end class='tag_cloud' -->\n";
  end

end
