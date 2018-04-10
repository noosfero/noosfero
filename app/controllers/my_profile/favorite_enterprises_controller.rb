class FavoriteEnterprisesController < MyProfileController

#  protect 'manage_favorite_enterprises', :profile

  requires_profile_class Person

  def index
    @favorite_enterprises = profile.favorite_enterprises.paginate(per_page: per_page, page: params[:npage])
  end

  def add
    @favorite_enterprise = Enterprise.find(params[:id])
    if request.post? && params[:confirmation]
      profile.favorite_enterprises << @favorite_enterprise
      redirect_to :action => 'index'
    end
  end

  def remove
    @favorite_enterprise = profile.favorite_enterprises.find(params[:id])
    if request.post? && params[:confirmation]
      profile.favorite_enterprises.delete(@favorite_enterprise)
      redirect_to :action => 'index'
    end
  end

  protected

    def per_page
      10
    end

end
