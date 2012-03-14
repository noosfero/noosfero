class MapBalloonController < PublicController

  helper SearchHelper

  before_filter :load_profile, :only => [:person, :enterprise, :community]

  def product
    @product = Product.find(params[:id])
    render :action => 'product', :layout => false
  end

  def person
    render :action => 'profile', :layout => false
  end

  def enterprise
    render :action => 'profile', :layout => false
  end

  def community
    render :action => 'profile', :layout => false
  end

  protected

  def load_profile
    @profile = Profile.find(params[:id])
  end

end
