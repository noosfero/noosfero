class ProfileSearchController < PublicController

  include SearchHelper

  needs_profile
  before_filter :check_access_to_profile

  def index
    @q = params[:q]
    unless @q.blank?
      if params[:where] == 'environment'
        redirect_to :controller => 'search', :query => @q
      else
        @results = profile.articles.published.find_by_contents(@q)[:results].paginate(:per_page => 10, :page => params[:page])
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
