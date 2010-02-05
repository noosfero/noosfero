class CommunitiesBlock < ProfileListBlock

  def self.description
    __('Communities')
  end

  def default_title
    n__('{#} community', '{#} communities', profile_count)
  end

  def profile_image_link_method
    :community_image_link
  end

  def help
    __('This block displays the communities in which the user is a member.')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to s_('communities|View all'), :profile => owner.identifier, :controller => 'profile', :action => 'communities'
      end
    when Environment
      lambda do
        link_to s_('communities|View all'), :controller => 'search', :action => 'assets', :asset => 'communities'
      end
    else
      ''
    end
  end

  def profile_count
    if owner.kind_of?(Environment)
      owner.communities.count(:conditions => { :visible => true })
    else
      owner.communities(:visible => true).count
    end
  end

  def profile_finder
    @profile_finder ||= CommunitiesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      # FIXME when owner is an environment (i.e. listing communities globally
      # this can become SLOW)
      if block.owner.kind_of?(Environment)
        block.owner.communities.all(:conditions => {:visible => true}, :limit => block.limit, :order => 'random()').map(&:id)
      else
        block.owner.communities(:visible => true).map(&:id)
      end
    end
  end

end
