class CommunitiesBlock < ProfileListBlock

  def self.description
    __('A block that displays your communities')
  end

  def default_title
    __('Communities')
  end

  def help
    __('This block displays the communities in which the user is a member.')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to __('All communities'), :profile => owner.identifier, :controller => 'profile', :action => 'communities'
      end
    when Environment
      lambda do
        link_to __('All communities'), :controller => 'search', :action => 'assets', :asset => 'communities'
      end
    else
      ''
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
        Community.find(:all, :conditions => {:environment_id => block.owner.id, :public_profile => true}, :limit => block.limit, :order => 'random()').map(&:id)
      else
        block.owner.communities.select(&:public_profile).map(&:id)
      end
    end
  end

end
