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
    @article = Article.find(params[:id])
    if request.post?
      @article.last_changed_by = user
      if @article.update_attributes(params[:article])
        redirect_to :action => 'view', :id => @article.id
      end
    end

    render :action => "#{mime_type_to_action_name(@article.mime_type)}_edit"
  end

  def new
    # FIXME until now, use text/html by default
    type = params[:type] || 'text/html'

    @article = Article.new(params[:article])
    if params[:parent_id]
      @article.parent = profile.articles.find(params[:parent_id])
    end
    @article.profile = profile
    @article.last_changed_by = user
    if request.post?
      if @article.save
        redirect_to :action => 'view', :id => @article.id
      end
    end

    render :action => "#{mime_type_to_action_name(type)}_new"
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
