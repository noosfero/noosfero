class ProfileDesignController < BoxOrganizerController

  needs_profile

  def index
    render :action => 'index', :layout => true
  end

  def boxes_editor?
    true
  end
  protected :boxes_editor?

end
