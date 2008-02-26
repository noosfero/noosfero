class FriendsController < MyProfileController
  
  def index
    @friends = profile.friends
  end

  def add
    @friend = Person.find(params[:id])
    if request.post? && params[:confirmation]
      AddFriend.create!(:person => profile, :friend => @friend, :group_for_person => params[:group])

      flash[:notice] = _('%s still needs to accept being your friend.') % @friend.name
      # FIXME shouldn't redirect to the friend's page?
      redirect_to :action => 'index' 
    end
  end

end
