class FriendsController < MyProfileController

  def add
    @friend = Person.find(params[:id])
    if request.post? && params[:confirmation]
      AddFriend.create!(:person => user, :friend => @friend)

      # FIXME shouldn't redirect to the friend's page?
      redirect_to :action => 'index' 
    end
  end

end
