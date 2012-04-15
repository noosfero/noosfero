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
        @results = Article.find_by_contents(@q, {:per_page => 10, :page => params[:page]},
                                            {:filter_queries => ["profile_id:#{profile.id}", 'public:true']})[:results]
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
