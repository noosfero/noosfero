class CmsController < MyProfileController

  protect 'post_content', :profile, :only => [:edit, :new, :reorder, :delete]

  design :holder => :profile

  include CmsHelper

  ARTICLE_TYPES = [
    TinyMceArticle
  ]

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
    @article = profile.articles.find(params[:id])
    if request.post?
      @article.last_changed_by = user
      if @article.update_attributes(params[:article])
        redirect_to :action => 'view', :id => @article.id
        return
      end
    end
  end

  def new
    # user must choose an article type first
    type = params[:type]
    if type.blank?
      @article_types = []
      ARTICLE_TYPES.each do |type|
        @article_types.push({
          :name => type.name,
          :short_description => type.short_description,
          :description => type.description
        })
      end
      render :action => 'select_article_type'
      return
    end

    raise "Invalid article type #{type}" unless ARTICLE_TYPES.map {|item| item.name}.include?(type)
    klass = type.constantize
    @article = klass.new(params[:article])


    if params[:parent_id]
      @article.parent = profile.articles.find(params[:parent_id])
    end
    @article.profile = profile
    @article.last_changed_by = user
    if request.post?
      if @article.save
        redirect_to :action => 'view', :id => @article.id
        return
      end
    end

    render :action => 'edit'
  end

  post_only :set_home_page
  def set_home_page
    @article = profile.articles.find(params[:id])
    profile.home_page = @article
    profile.save!
    redirect_to :action => 'view', :id => @article.id
  end

  post_only :destroy
  def destroy
    @article = profile.articles.find(params[:id])
    @article.destroy
    redirect_to :action => (@article.parent ? 'view' : 'index'), :id => @article.parent
  end

end

