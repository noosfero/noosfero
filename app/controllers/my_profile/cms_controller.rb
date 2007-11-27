class CmsController < MyProfileController
  
  # FIXME add the access control again
  # protect 'post_content', :profile, :only => [:edit, :new, :reorder, :delete]

  def view
    @article = profile.articles.find(params[:id])
    @subitems = @article.children
  end

  def index
    @article = profile.home_page
    @subitems = profile.top_level_articles
    render :action => 'view'
  end

  post_only :set_home_page
  def set_home_page
    @article = profile.articles.find(params[:id])
    profile.home_page = @article
    profile.save!
    redirect_to :back
  end

  protected

  def profile
    Profile.find_by_identifier(params[:profile]) 
  end

  def user
    current_user.person
  end


end
