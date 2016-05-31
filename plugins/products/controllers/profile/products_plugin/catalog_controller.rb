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

    # inherit routes from core skipping use_relative_controller!
    def url_for options
      options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
      super options
    end
    helper_method :url_for

  end
end
