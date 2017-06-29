module ProductsPlugin
  class SearchController < ::SearchController

    helper ProductsHelper

    def products
      @scope = @environment.products
      full_text_search
    end

  end
end
