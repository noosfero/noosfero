class CmsController < MyProfileController

  protect 'edit_profile', :profile, :only => [:set_home_page]

  def self.protect_if(*args)
    before_filter(*args) do |c|
      user, profile = c.send(:user), c.send(:profile)
      if yield(c, user, profile)
        true
      else
        render_access_denied(c)
        false
      end
    end
  end

  protect_if :except => [:set_home_page, :edit, :destroy, :publish] do |c, user, profile|
    user && (user.has_permission?('post_content', profile) || user.has_permission?('publish_content', profile))
  end

  protect_if :only => [:edit, :destroy, :publish] do |c, user, profile|
    profile.articles.find(c.params[:id]).allow_post_content?(user)
  end

  alias :check_ssl_orig :check_ssl
  # Redefines the SSL checking to avoid requiring SSL when creating the "New
  # publication" button on article's public view.
  def check_ssl
    if ((params[:action] == 'new') && (!request.xhr?)) || (params[:action] != 'new')
      check_ssl_orig
    end
  end

  def boxes_holder
    profile
  end

  include CmsHelper

  def available_article_types
    articles = [
      TinyMceArticle,
      TextileArticle
    ]
    articles << Event unless profile.environment.enabled?(:disable_asset_events)
    parent_id = params ? params[:parent_id] : nil
    if !parent_id or !Article.find(parent_id).blog?
      articles += [
        RssFeed
      ]
    end
    if profile.enterprise?
      articles << EnterpriseHomepage
    end
    articles
  end

  def special_article_types
    [Folder, Blog, UploadedFile]
  end

  def view
    @article = profile.articles.find(params[:id])
    @subitems = @article.children.reject {|item| item.folder? }
    if @article.blog?
      @subitems.reject! {|item| item.class == RssFeed }
    end
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
    @type = params[:type] || @article.class.to_s

    refuse_blocks
    if !@article.nil? && @article.blog? || !@type.nil? && @type == 'Blog'
      @back_url = url_for(:controller => 'profile_editor', :profile => profile.identifier)
    end
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
    else
      if @type == 'Blog'
        @back_url = url_for(:controller => 'profile_editor', :profile => profile.identifier)
      end
      refuse_blocks
    end

    raise "Invalid article type #{@type}" unless valid_article_type?(@type)
    klass = @type.constantize
    article_data = environment.enabled?('articles_dont_accept_comments_by_default') ? { :accept_comments => false } : {}
    article_data.merge!(params[:article]) if params[:article]
    @article = klass.new(article_data)

    parent = check_parent(params[:parent_id])
    if parent
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
    profile.save(false)
    flash[:notice] = _('"%s" configured as home page.') % @article.name
    redirect_to :action => 'view', :id => @article.id
  end

  def upload_files
    @uploaded_files = []
    @article = @parent = check_parent(params[:parent_id])
    @target = @parent ? ('/%s/%s' % [profile.identifier, @parent.full_name]) : '/%s' % profile.identifier
    @folders = Folder.find(:all, :conditions => { :profile_id => profile })
    record_coming_from_public_view if @article
    if request.post? && params[:uploaded_files]
      params[:uploaded_files].each do |file|
        @uploaded_files << UploadedFile.create(:uploaded_data => file, :profile => profile, :parent => @parent) unless file == ''
      end
      @errors = @uploaded_files.select { |f| f.errors.any? }
      @back_to = params[:back_to]
      if @errors.any?
        if @back_to && @back_to == 'media_listing'
          flash[:notice] = _('Could not upload all files')
          redirect_back
        else
          render :action => 'upload_files', :parent_id => @parent_id
        end
      else
        if params[:back_to]
          redirect_back
        else
          redirect_to( if @parent
            {:action => 'view', :id => @parent.id}
          else
            {:action => 'index'}
          end)
        end
      end
    end
  end

  def destroy
    @article = profile.articles.find(params[:id])
    if request.post?
      @article.destroy
      redirect_to :action => (@article.parent ? 'view' : 'index'), :id => @article.parent
    end
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

  def publish
    @article = profile.articles.find(params[:id])
    record_coming_from_public_view
    @groups = profile.memberships - [profile]
    @marked_groups = []
    groups_ids = profile.memberships.map{|m|m.id.to_s}
    @marked_groups = params[:marked_groups].map do |item|
      if groups_ids.include?(item[:group_id])
        item.merge :group => Profile.find(item.delete(:group_id))
      end
    end.compact unless params[:marked_groups].nil?
    if request.post?
      @failed = {}
      @marked_groups.each do |item|
        task = ApproveArticle.create!(:article => @article, :name => item[:name], :target => item[:group], :requestor => profile)
        begin
          task.finish unless item[:group].moderated_articles?
        rescue Exception => ex
           @failed[ex.clean_message] ? @failed[ex.clean_message] << item[:group].name : @failed[ex.clean_message] = [item[:group].name]
        end
      end
      if @failed.blank?
        flash[:notice] = _("Your publish request was sent successfully")
        redirect_back
      end
    end
  end

  def media_listing
    if params[:image_folder_id]
      folder = profile.articles.find(params[:image_folder_id]) if !params[:image_folder_id].blank?
      @images = (folder ? folder.children : UploadedFile.find(:all, :order => 'created_at desc', :conditions => ["profile_id = ? AND parent_id is NULL", profile ])).select { |c| c.image? }
    elsif params[:document_folder_id]
      folder = profile.articles.find(params[:document_folder_id]) if !params[:document_folder_id].blank?
      @documents = (folder ? folder.children : UploadedFile.find(:all, :order => 'created_at desc', :conditions => ["profile_id = ? AND parent_id is NULL", profile ])).select { |c| c.kind_of?(UploadedFile) && !c.image? }
    else
      @documents = UploadedFile.find(:all, :order => 'created_at desc', :conditions => ["profile_id = ? AND parent_id is NULL", profile ])
      @images = @documents.select(&:image?)
      @documents -= @images
    end

    @images = @images.paginate(:per_page => per_page, :page => params[:ipage]) if @images
    @documents = @documents.paginate(:per_page => per_page, :page => params[:dpage]) if @documents

    @folders = Folder.find(:all, :conditions => { :profile_id => profile })
    @image_folders = @folders.select {|f| f.children.any? {|c| c.image?} }
    @document_folders = @folders.select {|f| f.children.any? {|c| !c.image? && c.kind_of?(UploadedFile) } }

    @back_to = 'media_listing'

    respond_to do |format|
      format.html { render :layout => false}
      format.js {
        render :update do |page|
          page.replace_html 'media-listing-folder-images', :partial => 'image_thumb', :locals => {:images => @images } if !@images.blank?
          page.replace_html 'media-listing-folder-documents', :partial => 'document_link', :locals => {:documents => @documents } if !@documents.blank?
        end
      }
    end
  end

  protected

  def redirect_back
    if params[:back_to] == 'control_panel'
      redirect_to :controller => 'profile_editor', :profile => @profile.identifier
    elsif params[:back_to] == 'public_view'
      redirect_to @article.view_url.merge(Noosfero.url_options)
    elsif params[:back_to] == 'media_listing'
      redirect_to :action => 'media_listing'
    elsif @article.parent
      redirect_to :action => 'view', :id => @article.parent
    elsif @article.folder? && !@article.blog? && @article.parent
      redirect_to :action => 'index'
    else
      redirect_back_or_default :action => 'index'
    end
  end

  def record_coming_from_public_view
    referer = request.referer
    referer.gsub!(/\?.*/, '') unless referer.nil?
    if (maybe_ssl(url_for(@article.url)).include?(referer)) || (@article == profile.home_page && maybe_ssl(url_for(profile.url)).include?(referer))
      @back_to = 'public_view'
      @back_url = @article.view_url
    end
    if !request.post? and @article.blog?
      store_location(request.referer)
    end
  end

  def record_creating_from_public_view
    referer = request.referer
    if (referer =~ Regexp.new("^#{(url_for(profile.url).sub('https:', 'https?:'))}")) || params[:back_to] == 'public_view'
      @back_to = 'public_view'
      @back_url = referer
    end
    if !request.post? and @article.blog?
      store_location(request.referer)
    end
  end

  def maybe_ssl(url)
    [url, url.sub('https:', 'http:')]
  end

  def valid_article_type?(type)
    (available_article_types + special_article_types).map {|item| item.name}.include?(type)
  end

  def check_parent(id)
    if !id.blank?
      parent = profile.articles.find(id)
      if ! parent.allow_children?
        raise ArgumentError.new("cannot create child of article which does not accept children")
      end
      parent
    else
      nil
    end
  end

  def refuse_blocks
    if ['TinyMceArticle', 'Event', 'EnterpriseHomepage'].include?(@type)
      @no_design_blocks = true
    end
  end

  def per_page
    10
  end
end

