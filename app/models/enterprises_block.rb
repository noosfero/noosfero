class EnterprisesBlock < ProfileListBlock

  def default_title
    __('{#} enterprises')
  end

  def help
    __('This block displays the enterprises where this user works.')
  end

  def self.description
    __('A block that displays your enterprises')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to __('View all'), :profile => owner.identifier, :controller => 'profile', :action => 'enterprises'
      end
    when Environment
      lambda do
        link_to __('View all'), :controller => 'search', :action => 'assets', :asset => 'enterprises'
      end
    else
      ''
    end
  end

  def profile_count
    owner.enterprises.count
  end

  def profile_finder
    @profile_finder ||= EnterprisesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      # FIXME when owner is an environment (i.e. listing enterprises globally
      # this can become SLOW)
      if block.owner.kind_of?(Environment)
        Enterprise.find(:all, :conditions => {:environment_id => block.owner.id, :public_profile => true}, :limit => block.limit, :order => 'random()').map(&:id)
      else
        block.owner.enterprises.select(&:public_profile).map(&:id)
      end
    end
  end

end
