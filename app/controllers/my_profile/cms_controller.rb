class CmsController < MyProfileController

  protect 'post_content', :profile, :except => [:set_home_page]
  protect 'edit_profile', :profile, :only => [:set_home_page]

  def boxes_holder
    profile
  end

  include CmsHelper

  ARTICLE_TYPES = [
    Folder,
    TinyMceArticle,
    TextileArticle,
    RssFeed,
    UploadedFile,
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
    @parent_id = params[:parent_id]
    @type = params[:type]
    if request.post?
      @article.last_changed_by = user
      if @article.update_attributes(params[:article])
        redirect_to :action => 'view', :id => @article.id
        return
      end
    end
  end

  def new
    # FIXME this method should share some logic wirh edit !!!

    # user must choose an article type first
    @type = params[:type]
    if @type.blank?
      @article_types = []
      ARTICLE_TYPES.each do |type|
        @article_types.push({
          :name => type.name,
          :short_description => type.short_description,
          :description => type.description
        })
      end
      @parent_id = params[:parent_id]
      render :action => 'select_article_type', :layout => false
      return
    end

    raise "Invalid article type #{@type}" unless ARTICLE_TYPES.map {|item| item.name}.include?(@type)
    klass = @type.constantize
    @article = klass.new(params[:article])


    if params[:parent_id]
      parent = profile.articles.find(params[:parent_id])
      if ! parent.allow_children?
        raise ArgumentError.new("cannot create child of article which does not accept children")
      end
      @article.parent = parent
      @parent_id = parent.id
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
    flash[:notice] = _('Article "%s" configured as home page.') % @article.name
    redirect_to :action => 'view', :id => @article.id
  end

  post_only :destroy
  def destroy
    @article = profile.articles.find(params[:id])
    @article.destroy
    redirect_to :action => (@article.parent ? 'view' : 'index'), :id => @article.parent
  end

end

