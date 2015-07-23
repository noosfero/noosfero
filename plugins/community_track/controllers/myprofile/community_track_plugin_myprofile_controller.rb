class CommunityTrackPluginMyprofileController < MyProfileController

  before_filter :allow_edit_track, :only => :save_order

  def save_order
    track = profile.articles.find(params[:track])
    track.reorder_steps(params[:step_ids])
    redirect_to track.url
  end

  protected

  def allow_edit_track
    render_access_denied unless profile.articles.find(params[:track]).allow_edit?(user)
  end

end
