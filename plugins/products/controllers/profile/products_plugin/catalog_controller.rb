module ProductsPlugin
  class CatalogController < ProfileController

    before_filter :check_profile

    include CatalogHelper

    def index
      catalog_load_index
    end

    protected

    def check_profile
      return if profile.enterprise?
      redirect_to controller: 'profile', profile: profile.identifier, action: 'index'
    end

  end
end
