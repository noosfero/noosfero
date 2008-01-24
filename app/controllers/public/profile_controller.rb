class ProfileController < ApplicationController
  needs_profile

  helper TagsHelper

  def index
    @tags = profile.tags
  end

  def tag
    @tag = params[:id]
    @tagged = profile.find_tagged_with(@tag)
  end

end
