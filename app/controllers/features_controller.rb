class FeaturesController < ApplicationController
  acts_as_virtual_community_admin_controller

  def index
    @features = VirtualCommunity::EXISTING_FEATURES
  end
end
