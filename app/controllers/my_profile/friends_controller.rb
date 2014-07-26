class FriendsController < MyProfileController
  
  protect 'manage_friends', :profile
  
  def index
    @suggestions = profile.suggested_people.limit(per_page/2)
    if is_cache_expired?(profile.manage_friends_cache_key(params))
      @friends = profile.friends.paginate(:per_page => per_page, :page => params[:npage])
    end
  end

  def remove
    @friend = profile.friends.find(params[:id])
    if request.post? && params[:confirmation]
      profile.remove_friend(@friend)
      redirect_to :action => 'index'
    end
  end

  def suggest
    @suggestions = profile.suggested_people.paginate(:per_page => per_page, :page => params[:npage])
  end

  def remove_suggestion
    @person = profile.suggested_people.find_by_identifier(params[:id])
    redirect_to :action => 'suggest' unless @person
    if @person && request.post?
      suggestion = profile.profile_suggestions.find_by_suggestion_id @person.id
      suggestion.disable
      session[:notice] = _('Suggestion removed')
      redirect_to :action => 'suggest'
    end
  end

  protected

  class << self
    def per_page
      10
    end
  end
  def per_page
    self.class.per_page
  end

end
