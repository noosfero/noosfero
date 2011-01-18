class ProfileSearchController < PublicController

  include SearchHelper

  needs_profile
  before_filter :check_access_to_profile

  def index
    @q = params[:q].blank? ? '' : params[:q]
    @filtered_query = remove_stop_words(@q)
    if params[:where] == 'environment'
      redirect_to :controller => 'search', :query => @q
    else
      @results = profile.articles.published.find_by_contents(@filtered_query).paginate(:per_page => 10, :page => params[:page])
    end
  end

  protected

  def check_access_to_profile
    unless profile.display_info_to?(user)
      redirect_to :controller => 'profile', :action => 'index'
    end
  end

end
