class CmsController < MyProfileController

  protect 'edit_profile', :profile, :only => [:set_home_page]

  include ArticleHelper

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

  before_filter :login_required, :except => [:suggest_an_article]

  protect_if :only => :upload_files do |c, user, profile|
    article_id = c.params[:parent_id]
    (!article_id.blank? && profile.articles.find(article_id).allow_create?(user)) ||
    (user && (user.has_permission?('post_content', profile) || user.has_permission?('publish_content', profile)))
  end

  protect_if :except => [:suggest_an_article, :set_home_page, :edit, :destroy, :publish, :upload_files, :new] do |c, user, profile|
    user && (user.has_permission?('post_content', profile) || user.has_permission?('publish_content', profile))
  end

  protect_if :only => :new do |c, user, profile|
    article = profile.articles.find_by_id(c.params[:parent_id])
    (!article.nil? && (article.allow_create?(user) || article.parent.allow_create?(user))) ||
    (user && (user.has_permission?('post_content', profile) || user.has_permission?('publish_content', profile)))
  end

  protect_if :only => [:destroy, :publish] do |c, user, profile|
    profile.articles.find(c.params[:id]).allow_post_content?(user)
  end

  protect_if :only => :edit do |c,user,profile|
    profile.articles.find(c.params[:id]).allow_edit?(user)
  end

  def boxes_holder
    profile
  end

  def view
    @article = profile.articles.find(params[:id])
    conditions = []
    if @article.has_posts?
      conditions = ['type != ?', 'RssFeed']
    end

    @articles = @article.children.reorder("case when type = 'Folder' then 0 when type ='Blog' then 1 else 2 end, updated_at DESC, name").paginate(
      :conditions => conditions,
      :per_page => per_page,
      :page => params[:npage]
    )
  end

  def index
    @article = nil
    @articles = profile.top_level_articles.paginate(
      :order => "case when type = 'Folder' then 0 when type ='Blog' then 1 else 2 end, updated_at DESC",
      :per_page => per_page,
      :page => params[:npage]
    )
    render :action => 'view'
  end

  def edit
    @success_back_to = params[:success_back_to]
    @article = profile.articles.find(params[:id])
    version = params[:version]
    @article.revert_to(version) if version

    @parent_id = params[:parent_id]
    @type = params[:type] || @article.class.to_s
    translations if @article.translatable?
    continue = params[:continue]

    @article.article_privacy_exceptions = params[:q].split(/,/).map{|n| environment.people.find n.to_i} unless params[:q].nil?

    @tokenized_children = prepare_to_token_input(
                            profile.members.includes(:articles_with_access).find_all{ |m|
                              m.articles_with_access.include?(@article)
                            }
                          )
    refuse_blocks
    record_coming
    if request.post?
      @article.image = nil if params[:remove_image] == 'true'
      @article.last_changed_by = user
      if @article.update_attributes(params[:article])
        if !continue
          if @article.content_type.nil? || @article.image?
            success_redirect
          else
            redirect_to :action => (@article.parent ? 'view' : 'index'), :id => @article.parent
          end
        end
      end
    end
  end

  def new
    # FIXME this method should share some logic wirh edit !!!

    @success_back_to = params[:success_back_to]
    # user must choose an article type first

    @parent = profile.articles.find(params[:parent_id]) if params && params[:parent_id]
    record_coming
    @type = params[:type]
    if @type.blank?
      @article_types = []
      available_article_types.each do |type|
        @article_types.push({
          :class => type,
          :short_description => type.short_description,
          :description => type.description
        })
      end
      @parent_id = params[:parent_id]
      render :action => 'select_article_type', :layout => false, :back_to => @back_to
      return
    else
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

    @article.profile = profile
    @article.last_changed_by = user

    translations if @article.translatable?

    continue = params[:continue]
    if request.post?
      @article.article_privacy_exceptions = params[:q].split(/,/).map{|n| environment.people.find n.to_i} unless params[:q].nil?

      if @article.save
        if continue
          redirect_to :action => 'edit', :id => @article
        else
          success_redirect
        end
        return
      end
    end

    render :action => 'edit'
  end

  post_only :set_home_page
  def set_home_page
    article = params[:id].nil? ? nil : profile.articles.find(params[:id])
    profile.update_attribute(:home_page, article)

    if article.nil?
      session[:notice] = _('Homepage reseted.')
    else
      session[:notice] = _('"%s" configured as homepage.') % article.name
    end

    redirect_to (request.referer || profile.url)
  end

  def upload_files
    @uploaded_files = []
    @article = @parent = check_parent(params[:parent_id])
    @target = @parent ? ('/%s/%s' % [profile.identifier, @parent.full_name]) : '/%s' % profile.identifier
    if @article
      record_coming
    end
    if request.post? && params[:uploaded_files]
      params[:uploaded_files].each do |file|
        @uploaded_files << UploadedFile.create({:uploaded_data => file, :profile => profile, :parent => @parent, :last_changed_by => user}, :without_protection => true) unless file == ''
      end
      @errors = @uploaded_files.select { |f| f.errors.any? }
      if @errors.any?
        render :action => 'upload_files', :parent_id => @parent_id
      else
        if @back_to
          redirect_to @back_to
        elsif @parent
          redirect_to :action => 'view', :id => @parent.id
        else
          redirect_to :action => 'index'
        end
      end
    end
  end

  def destroy
    @article = profile.articles.find(params[:id])
    if request.post?
      @article.destroy
      session[:notice] = _("\"#{@article.name}\" was removed.")
      referer = Rails.application.routes.recognize_path URI.parse(request.referer).path rescue nil
      if referer and referer[:controller] == 'cms' and referer[:action] != 'edit'
        redirect_to referer
      elsif @article.parent
        redirect_to @article.parent.url
      else
        redirect_to profile.url
      end
    end
  end

  def why_categorize
    render :action => params[:action], :layout => false
  end

  def update_categories
    @object = params[:id] ? @profile.articles.find(params[:id]) : Article.new
    @categories = @toplevel_categories = environment.top_level_categories
    if params[:category_id]
      @current_category = Category.find(params[:category_id])
      @categories = @current_category.children
    end
    render :template => 'shared/update_categories', :locals => { :category => @current_category }
  end

  def publish
    @article = profile.articles.find(params[:id])
    record_coming
    @groups = profile.memberships - [profile]
    @marked_groups = []
    groups_ids = profile.memberships.map{|m|m.id.to_s}
    @marked_groups = params[:marked_groups].map do |key, item|
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
           @failed[ex.message] ? @failed[ex.message] << item[:group].name : @failed[ex.message] = [item[:group].name]
        end
      end
      if @failed.blank?
        session[:notice] = _("Your publish request was sent successfully")
        if @back_to
          redirect_to @back_to
        else
          redirect_to @article.view_url
        end
      end
    end
  end

  def publish_on_portal_community
    @article = profile.articles.find(params[:id])
    if request.post?
      if environment.portal_community
        task = ApproveArticle.create!(:article => @article, :name => params[:name], :target => environment.portal_community, :requestor => user)
        begin
          task.finish unless environment.portal_community.moderated_articles?
          flash[:notice] = _("Your publish request was sent successfully")
        rescue
          flash[:error] = _("Your publish request couldn't be sent.")
        end
      else
        flash[:notice] = _("There is no portal community to publish your article.")
      end

      if @back_to
        redirect_to @back_to
      else
        redirect_to @article.view_url
      end
    end
  end

  def suggest_an_article
    @back_to = params[:back_to] || request.referer || url_for(profile.public_profile_url)
    @task = SuggestArticle.new(params[:task])
    if request.post?
      @task.target = profile
      @task.ip_address = request.remote_ip
      @task.user_agent = request.user_agent
      @task.referrer = request.referrer
      if verify_recaptcha(:model => @task, :message => _('Please type the words correctly')) && @task.save
        session[:notice] = _('Thanks for your suggestion. The community administrators were notified.')
        redirect_to @back_to
      end
    end
  end

  def search
    query = params[:q]
    results = find_by_contents(:uploaded_files, profile.files.published, query)[:results]
    render :text => article_list_to_json(results), :content_type => 'application/json'
  end

  def search_article_privacy_exceptions
    arg = params[:q].downcase
    result = profile.members.find(:all, :conditions => ['LOWER(name) LIKE ?', "%#{arg}%"])
    render :text => prepare_to_token_input(result).to_json
  end

  def media_upload
    files_uploaded = []
    parent = check_parent(params[:parent_id])
    files = [:file1,:file2, :file3].map { |f| params[f] }.compact
    if request.post?
      files.each do |file|
        files_uploaded << UploadedFile.create(:uploaded_data => file, :profile => profile, :parent => parent) unless file == ''
      end
    end
    render :text => article_list_to_json(files_uploaded), :content_type => 'text/plain'
  end

  protected

  include CmsHelper

  def available_article_types
    articles = [
      TinyMceArticle,
      TextileArticle,
      Event
    ]
    articles += special_article_types if params && params[:cms]
    parent_id = params ? params[:parent_id] : nil
    if profile.enterprise?
      articles << EnterpriseHomepage
    end
    if @parent && @parent.blog?
      articles -= Article.folder_types.map(&:constantize)
    end
    if user.is_admin?(profile.environment)
      articles << RawHTMLArticle
    end
    articles
  end

  def special_article_types
    [Folder, Blog, UploadedFile, Forum, Gallery, RssFeed] + @plugins.dispatch(:content_types)
  end


  def record_coming
    if request.post?
      @back_to = params[:back_to]
    else
      @back_to = params[:back_to] || request.referer
    end
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
    if ['TinyMceArticle', 'TextileArticle', 'Event', 'EnterpriseHomepage'].include?(@type)
      @no_design_blocks = true
    end
  end

  def per_page
    10
  end

  def translations
    @locales = environment.locales.invert.reject { |name, lang| !@article.possible_translations.include?(lang) }
    @selected_locale = @article.language || FastGettext.locale
  end

  def article_list_to_json(list)
    list.map do |item|
      {
        'title' => item.title,
        'url' => item.image? ? item.public_filename(:uploaded) : url_for(item.url),
        :icon => icon_for_article(item),
        :content_type => item.mime_type,
        :error => item.errors.any? ? _('%s could not be uploaded') % item.title : nil,
      }
    end.to_json
  end

  def content_editor?
    true
  end

  def success_redirect
    if !@success_back_to.blank?
      redirect_to @success_back_to
    else
      redirect_to @article.view_url
    end
  end

end
