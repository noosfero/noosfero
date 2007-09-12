class ProfileEditorController < ApplicationController
  helper :profile

  # edits the profile info (posts back)
  def edit
    if request.post?
    else
      render :action => profile.info.class.tableize
    end
  end
end

