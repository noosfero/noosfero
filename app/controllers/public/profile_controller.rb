class ProfileController < ApplicationController

  needs_profile
  before_filter :check_access_to_profile

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

  def sitemap
    @articles = profile.top_level_articles
  end

  protected

  def check_access_to_profile
    unless profile.display_info_to?(user)
      render :action => 'private_profile', :status => 403, :layout => false
    end
  end

end
