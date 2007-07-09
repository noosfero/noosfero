class FeaturesController < ApplicationController
  acts_as_admin_controller

  def index
    @features = VirtualCommunity::EXISTING_FEATURES
  end
end
