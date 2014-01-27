class TagsBlock < Block

  include TagsHelper
  include BlockHelper
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

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

  def content(args={})
    is_env = owner.class == Environment
    tags = is_env ? owner.tag_counts : owner.article_tags
    return '' if tags.empty?

    if limit
      tags_tmp = tags.sort_by{ |k,v| -v }[0..(limit-1)]
      tags = {}
      tags_tmp.map{ |k,v| tags[k] = v }
    end

    url = is_env ? {:host=>owner.default_hostname, :controller=>'search', :action => 'tag'} :
          owner.public_profile_url.merge(:controller => 'profile', :action => 'content_tagged')
    tagname_option = is_env ? :tag : :id

    block_title(title) +
    "\n<div class='tag_cloud'>\n".html_safe+
    tag_cloud( tags, tagname_option, url, :max_size => 16, :min_size => 9 ) +
    "\n</div><!-- end class='tag_cloud' -->\n".html_safe
  end

  def footer
    if owner.class == Environment
      proc do
        link_to s_('tags|View all'),
          :controller => 'search', :action => 'tags'
      end
    else
      owner_id = owner.identifier
      proc do
        link_to s_('tags|View all'),
          :profile => owner_id, :controller => 'profile', :action => 'tags'
      end
    end
  end

  def timeout
    15.minutes
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end

end
