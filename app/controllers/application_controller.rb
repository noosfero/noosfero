# his is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

  include ApplicationHelper
  layout :get_layout
  def get_layout
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

  def boxes_editor?
    false
  end
  protected :boxes_editor?

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
    FastGettext.available_locales = Noosfero.available_locales
    FastGettext.default_locale = Noosfero.default_locale
    FastGettext.set_locale(params[:lang] || session[:lang] || Noosfero.default_locale || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
    if params[:lang]
      session[:lang] = params[:lang]
    end
  end

  include NeedsProfile

  before_filter :detect_stuff_by_domain
  before_filter :init_noosfero_plugins
  attr_reader :environment

  before_filter :load_terminology

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    verify :method => :post, :only => actions, :redirect_to => redirect
  end

  helper_method :current_person, :current_person

  protected

  def user
    current_user.person if logged_in?
  end
  
  alias :current_person :user

  # TODO: move this logic somewhere else (Domain class?)
  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @environment = Environment.default
    else
      @environment = @domain.environment
      @profile = @domain.profile
    end
  end

  def init_noosfero_plugins
    @plugins = Noosfero::Plugin::Manager.new(self)
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
