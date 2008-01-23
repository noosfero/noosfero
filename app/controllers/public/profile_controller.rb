class ProfileController < ApplicationController
  needs_profile

  helper TagsHelper

  def index
    @tags = profile.tags
  end

  def tag
    @tag = profile.content_tagged_with(params[:id])
  end

end
