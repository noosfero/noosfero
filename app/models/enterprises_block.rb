class EnterprisesBlock < ProfileListBlock

  def default_title
    __('Enterprises')
  end

  def help
    __('The enterprises where this user works.')
  end

  def self.description
    __('A block that displays your enterprises')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to __('All enterprises'), :profile => owner.identifier, :controller => 'profile', :action => 'enterprises'
      end
    when Environment
      lambda do
        link_to __('All enterprises'), :controller => 'search', :action => 'assets', :asset => 'enterprises'
      end
    else
      ''
    end
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
