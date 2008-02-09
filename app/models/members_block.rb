class MembersBlock < ProfileListBlock

  def self.description
    _('A block that displays members.')
  end

  def title
    _('Members')
  end

  def footer
    profile = self.owner
    lambda do
      link_to _('All members'), :profile => profile.identifier, :controller => 'profile', :action => 'members'
    end
  end

  class Finder

    def initialize(members)
      @members = members
    end

    # FIXME optimize this !!!
    def find(options)
      Profile.find(:all, options.merge(:conditions => { :id => @members.map(&:id) }))
    end
  end

  def profile_finder
    @profile_finder ||= Finder.new(owner.members)
  end

end
