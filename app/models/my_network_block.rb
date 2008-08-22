class MyNetworkBlock < Block

  include ActionController::UrlWriter

  def self.description
    _('A block that displays a summary of your network')
  end

  def default_title
    _('My network')
  end

  def content
    block_title(title) +
    content_tag(
      'ul',
      content_tag('li', link_to(n_( 'One article published', '%s articles published', owner.articles.count) %
                  content_tag('b', owner.articles.count), owner.public_profile_url.merge(:action => 'sitemap') )) +
      content_tag('li', link_to(n__('One friend', '%s friends', owner.friends.count) %
                  content_tag('b', owner.friends.count), owner.public_profile_url.merge(:action => 'friends'))) +
      content_tag('li', link_to(n__('One community', '%s communities', owner.communities.size) %
                  content_tag('b', owner.communities.size), owner.public_profile_url.merge(:action => 'communities'))) +
      content_tag('li', link_to(n_('One tag', '%s tags', owner.tags.size) %
                  content_tag('b', owner.tags.size), owner.public_profile_url.merge(:action => 'tags')))
    )
  end

end
