class EnterprisesBlock < ProfileListBlock

  def default_title
    _('Enterprises')
  end

  def help
    _('The enterprises where this user works.')
  end

  def self.description
    _('A block that displays your enterprises')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to _('All enterprises'), :profile => owner.identifier, :controller => 'profile', :action => 'enterprises'
      end
    when Environment
      lambda do
        link_to _('All enterprises'), :controller => 'search', :action => 'assets', :asset => 'enterprises'
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
      block.owner.enterprises.map(&:id)
    end
  end

end
