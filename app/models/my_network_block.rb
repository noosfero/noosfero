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
      content_tag('li', link_to(n_( 'One article published', '%d articles published', owner.articles.count) % owner.articles.count, owner.public_profile_url.merge(:action => 'sitemap') )) +
      content_tag('li', link_to(n__('One friend', '%d friends', owner.friends.count) % owner.friends.count, owner.public_profile_url.merge(:action => 'friends'))) +
      content_tag('li', link_to(n__('One community', '%d communities', owner.communities.count) % owner.communities.count, owner.public_profile_url.merge(:action => 'communities'))) +
      content_tag('li', link_to(n_('One tag', '%d tags', owner.tags.count) % owner.tags.count, owner.public_profile_url.merge(:action => 'tags')))
    )
  end

end
