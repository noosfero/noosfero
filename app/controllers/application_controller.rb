class ApplicationController < ActionController::Base

  before_filter :setup_multitenancy
  before_filter :detect_stuff_by_domain
  before_filter :init_noosfero_plugins

  include ApplicationHelper
  layout :get_layout
  def get_layout
    prepend_view_path('public/' + theme_path)
    theme_option(:layout) || 'application'
  end

  filter_parameter_logging :password

  def log_processing
    super
    return unless ENV['RAILS_ENV'] == 'production'
    if logger && logger.info?
      logger.info("  HTTP Referer: #{request.referer}")
      logger.info("  User Agent: #{request.user_agent}")
      logger.info("  Accept-Language: #{request.headers['HTTP_ACCEPT_LANGUAGE']}")
    end
  end

  helper :document
  helper :language

  def self.no_design_blocks
    @no_design_blocks = true
  end
  def self.uses_design_blocks?
    !@no_design_blocks
  end
  def uses_design_blocks?
    !@no_design_blocks && self.class.uses_design_blocks?
  end

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include PermissionCheck

  before_filter :set_locale
  def set_locale
    FastGettext.available_locales = environment.available_locales
    FastGettext.default_locale = environment.default_locale
    FastGettext.locale = (params[:lang] || session[:lang] || environment.default_locale || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
    I18n.locale = FastGettext.locale
    if params[:lang]
      session[:lang] = params[:lang]
    end
  end

  include NeedsProfile

  attr_reader :environment

  before_filter :load_terminology

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    verify :method => :post, :only => actions, :redirect_to => redirect
  end

  helper_method :current_person, :current_person

  protected

  def setup_multitenancy
    Noosfero::MultiTenancy.setup!(request.host)
  end

  def boxes_editor?
    false
  end

  def content_editor?
    false
  end


  def user
    current_user.person if logged_in?
  end
  
  alias :current_person :user

  # TODO: move this logic somewhere else (Domain class?)
  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @environment = Environment.default
      if @environment.nil? && Rails.env.development?
        # This should only happen in development ...
        @environment = Environment.create!(:name => "Noosfero", :is_default => true)
      end
    else
      @environment = @domain.environment
      @profile = @domain.profile
    end
  end

  include Noosfero::Plugin::HotSpot

  def init_noosfero_plugins
    plugins.each do |plugin|
      prepend_view_path(plugin.class.view_path)
    end
    init_noosfero_plugins_controller_filters
  end

  # This is a generic method that initialize any possible filter defined by a
  # plugin to the current controller being initialized.
  def init_noosfero_plugins_controller_filters
    plugins.each do |plugin|
      filters = plugin.send(self.class.name.underscore + '_filters')
      filters = [filters] if !filters.kind_of?(Array)
      filters.each do |plugin_filter|
        self.class.send(plugin_filter[:type], plugin.class.name.underscore + '_' + plugin_filter[:method_name], (plugin_filter[:options] || {}))
        self.class.send(:define_method, plugin.class.name.underscore + '_' + plugin_filter[:method_name], plugin_filter[:block])
      end
    end
  end

  def load_terminology
    # cache terminology for performance
    @@terminology_cache ||= {}
    @@terminology_cache[environment.id] ||= environment.terminology
    Noosfero.terminology = @@terminology_cache[environment.id]
  end

  def render_not_found(path = nil)
    @no_design_blocks = true
    @path ||= request.path
    render :template => 'shared/not_found.rhtml', :status => 404, :layout => get_layout
  end
  alias :render_404 :render_not_found

  def render_access_denied(message = nil, title = nil)
    @no_design_blocks = true
    @message = message
    @title = title
    render :template => 'shared/access_denied.rhtml', :status => 403
  end

  def load_category
    unless params[:category_path].blank?
      path = params[:category_path].join('/')
      @category = environment.categories.find_by_path(path)
      if @category.nil?
        render_not_found(path)
      end
    end
  end

end
