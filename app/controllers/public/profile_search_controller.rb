class ProfileSearchController < PublicController

  include SearchHelper

  needs_profile
  before_filter :check_access_to_profile

  def index
    @q = params[:q]
    unless @q.blank?
      if params[:where] == 'environment'
        # user is using global search, redirects to the search controller with
        # the query
        search_path = url_for(:controller => 'search', :query => @q)
        request.xhr? ? render(:js => "window.location.href = #{search_path.to_json}") : redirect_to(search_path)
      else
        @results = find_by_contents(:articles, profile, profile.articles.published, @q, {:per_page => 10, :page => params[:page]})[:results]
      end
    end
  end

  protected

  def check_access_to_profile
    unless profile.display_info_to?(user)
      redirect_to :controller => 'profile', :action => 'index'
    end
  end

end
