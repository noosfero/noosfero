class FriendsController < MyProfileController
  
  protect 'manage_friends', :profile
  
  def index
    @suggestions = profile.profile_suggestions.of_person.enabled.includes(:suggestion).limit(per_page)
    if is_cache_expired?(profile.manage_friends_cache_key(params))
      @friends = profile.friends.paginate(:per_page => per_page, :page => params[:npage])
    end
  end

  def remove
    @friend = profile.friends.find(params[:id])
    if request.post? && params[:confirmation]
      Friendship.remove_friendship(profile, @friend)
      redirect_to :action => 'index'
    end
  end

  def suggest
    @suggestions = profile.profile_suggestions.of_person.enabled.includes(:suggestion).limit(per_page)
  end

  def remove_suggestion
    @person = profile.suggested_people.find_by_identifier(params[:id])
    redirect_to :action => 'suggest' unless @person
    if @person && request.post?
      profile.remove_suggestion(@person)
      @suggestions = profile.profile_suggestions.of_person.enabled.includes(:suggestion).limit(per_page)
      render :partial => 'shared/profile_suggestions_list', :locals => { :suggestions => @suggestions, :collection => :friends_suggestions, :per_page => params[:per_page] || per_page }
    end
  end

  def connections
    @suggestion = profile.profile_suggestions.of_person.enabled.find_by_suggestion_id(params[:id])
    if @suggestion
      @tags = @suggestion.tag_connections
      @profiles = @suggestion.profile_connections
    else
      redirect_to :action => 'suggest'
    end
  end

  protected

  class << self
    def per_page
      12
    end
  end
  def per_page
    self.class.per_page
  end

end
