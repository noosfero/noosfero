class CommunitiesBlock < ProfileListBlock

  attr_accessible :accessor_id, :accessor_type, :role_id, :resource_id, :resource_type

  def self.description
    _('Communities')
  end

  def default_title
    n_('{#} community', '{#} communities', profile_count)
  end

  def help
    _('This block displays the communities in which the user is a member.')
  end

  def suggestions
    return nil unless owner.kind_of?(Profile)
    owner.profile_suggestions.of_community.enabled.limit(3).includes(:suggestion)
  end

  def footer
    owner = self.owner
    suggestions = self.suggestions
    return '' unless owner.kind_of?(Profile) || owner.kind_of?(Environment)
    proc do
      render :file => 'blocks/communities', :locals => { :owner => owner, :suggestions => suggestions }
    end
  end

  def profiles
    owner.communities
  end

end
