class PeopleBlock < ProfileListBlock

  def title
    _('People')
  end

  def help
    _('Clicking a person takes you to his/her homepage')
  end

  def self.description
    _('A block displays random people')
  end

  def profile_finder
    @profile_finder ||= PeopleBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      Person.find(:all, :select => 'id', :conditions => { :environment_id => block.owner.id})
    end
  end

end
