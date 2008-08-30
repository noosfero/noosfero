class CmsController < MyProfileController

  protect 'post_content', :profile, :except => [:set_home_page]
  protect 'edit_profile', :profile, :only => [:set_home_page]

  def boxes_holder
    profile
  end

  include CmsHelper

  def available_article_types
    articles = [
      Folder,
      TinyMceArticle,
      TextileArticle,
      RssFeed,
      UploadedFile,
      Event
    ]
    if profile.enterprise?
      articles << EnterpriseHomepage
    end
    articles
  end

  def view
    @article = profile.articles.find(params[:id])
    @subitems = @article.children.reject {|item| item.folder? }
    @folders = @article.children.select {|item| item.folder? }
  end

  def index
    @article = nil
    @subitems = profile.top_level_articles.reject {|item| item.folder? }
    @folders = profile.top_level_articles.select {|item| item.folder?}
    render :action => 'view'
  end

  def edit
    @article = profile.articles.find(params[:id])
    @parent_id = params[:parent_id]
    @type = params[:type]
    record_coming_from_public_view
    if request.post?
      @article.last_changed_by = user
      if @article.update_attributes(params[:article])
        redirect_back
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
      available_article_types.each do |type|
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

    raise "Invalid article type #{@type}" unless available_article_types.map {|item| item.name}.include?(@type)
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

    record_creating_from_public_view

    @article.profile = profile
    @article.last_changed_by = user
    if request.post?
      if @article.save
        redirect_back
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

  def why_categorize
    render :action => params[:action], :layout => false
  end

  def update_categories
    @object = params[:id] ? @profile.articles.find(params[:id]) : Article.new
    if params[:category_id]
      @current_category = Category.find(params[:category_id])
      @categories = @current_category.children
    else
      @categories = environment.top_level_categories.select{|i| !i.children.empty?}
    end
    render :partial => 'shared/select_categories', :locals => {:object_name => 'article', :multiple => true}, :layout => false
  end

  protected

  def redirect_back
    if params[:back_to] == 'public_view'
      redirect_to @article.url
    elsif @article.parent
      redirect_to :action => 'view', :id => @article.parent
    else
      redirect_to :action => 'index'
    end
  end

  def record_coming_from_public_view
    referer = request.referer
    if (referer == url_for(@article.url)) || (@article == @profile.home_page && referer == url_for(@profile.url))
      @back_to = 'public_view'
      @back_url = @article.url
    end
  end

  def record_creating_from_public_view
    referer = request.referer
    if (referer =~ Regexp.new("^#{url_for(profile.url)}"))
      @back_to = 'public_view'
      @back_url = referer
    end
  end

end

