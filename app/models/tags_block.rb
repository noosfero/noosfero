class TagsBlock < Block

  include TagsHelper
  include BlockHelper
  include ActionController::UrlWriter

  settings_items :limit, :type => :integer, :default => 12

  def self.description
    _('Tags')
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

    if limit
      tags_tmp = tags.sort_by{ |k,v| -v }[0..(limit-1)]
      tags = {}
      tags_tmp.map{ |k,v| tags[k] = v }
    end

    block_title(title) +
    "\n<div class='tag_cloud'>\n"+
    tag_cloud( tags, :id,
               owner.public_profile_url.merge(:controller => 'profile', :action => 'tags'),
               :max_size => 16, :min_size => 9 ) +
    "\n</div><!-- end class='tag_cloud' -->\n";
  end

  def footer
    owner_id = owner.identifier
    lambda do
      link_to s_('tags|View all'), :profile => owner_id, :controller => 'profile', :action => 'tags'
    end
  end

  def timeout
    15.minutes
  end

end
