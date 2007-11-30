class FavoriteLinksProfileController < FavoriteLinksController

  needs_profile

  acts_as_design_block

#  before_filter :bli
  def bli
    raise "bli"
  end

end
