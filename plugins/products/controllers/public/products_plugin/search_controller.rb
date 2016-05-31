module ProductsPlugin
  class SearchController < ::SearchController

    helper ProductsHelper

    def products
      @scope = @environment.products
      full_text_search
    end

    protected

    # inherit routes from core skipping use_relative_controller!
    def url_for options
      options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
      super options
    end
    helper_method :url_for

  end
end
