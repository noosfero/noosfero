class CmsController < MyProfileController

  # FIXME add the access control again
  # protect 'post_content', :profile, :only => [:edit, :new, :reorder, :delete]

  design :holder => :profile

  include CmsHelper

  def view
    @article = profile.articles.find(params[:id])
    @subitems = @article.children
  end

  def index
    @article = nil
    @subitems = profile.top_level_articles
    render :action => 'view'
  end

  def edit
    article = profile.articles.find(params[:id])
    redirect_to(url_for_edit_article(article))
  end

  post_only :set_home_page
  def set_home_page
    @article = profile.articles.find(params[:id])
    profile.home_page = @article
    profile.save!
    redirect_to :back
  end

  protected

  class << self
    def available_editors
      Dir.glob(File.join(File.dirname(__FILE__), 'cms', '*.rb'))
    end

    def available_types
      available_editors.map {|item| File.basename(item).gsub(/\.rb$/, '').gsub('_', '/')  }
    end
  end

end

CmsController.available_editors.each do |item|
  load item
end
