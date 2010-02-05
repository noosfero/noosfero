class PeopleBlock < ProfileListBlock

  def default_title
    _('People')
  end

  def help
    _('Clicking a person takes you to his/her homepage')
  end

  def self.description
    _('Random people')
  end

  def profile_finder
    @profile_finder ||= PeopleBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      block.owner.people.visible.all(:limit => block.limit, :order => 'random()').map(&:id)
    end
  end

  def footer
    lambda do
      link_to _('View all'), :controller => 'search', :action => 'assets', :asset => 'people'
    end
  end

  def profile_count
    owner.people.visible.count
  end

end
