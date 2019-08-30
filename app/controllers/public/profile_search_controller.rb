class ProfileSearchController < PublicController
  include SearchHelper

  needs_profile
  before_action :check_access_to_profile

  def index
    @q = params[:q]
    @asset = :articles
    @searches = {}
    if params[:where] == "environment"
      # user is using global search, redirects to the search controller with
      # the query
      search_path = url_for(controller: "search", query: @q)
      request.xhr? ? render(js: "window.location.href = #{search_path.to_json}") : redirect_to(search_path)
    else
      @searches[@asset] = find_by_contents(@asset, profile, profile.articles.published, @q, { per_page: 10, page: params[:page] },
                                           { facets: params[:facets], periods: params[:periods], block: params[:block] })
      @results = @searches[@asset][:results]
    end
  end

  protected

    def check_access_to_profile
      unless profile.display_to?(user)
        redirect_to controller: "profile", action: "index"
      end
    end
end
