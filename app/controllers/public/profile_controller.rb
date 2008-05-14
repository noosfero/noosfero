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

  def communities
    @communities = profile.communities
  end

  def enterprises
    @enterprises = profile.enterprises
  end

  def friends
    @friends= profile.friends
  end

  def members
    @members = profile.members
  end

  def favorite_enterprises
    @favorite_enterprises = profile.favorite_enterprises
  end
end
