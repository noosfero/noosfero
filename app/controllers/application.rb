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

  def self.require_ssl(*options)
    before_filter :check_ssl, *options
  end
  def check_ssl
    return true if (request.ssl? || ENV['RAILS_ENV'] == 'development')
    redirect_to_ssl
  end
  def redirect_to_ssl
    if environment.enable_ssl
      redirect_to(params.merge(:protocol => 'https://', :host => ssl_hostname))
      true
    else
      false
    end
  end

  def self.refuse_ssl(*options)
    before_filter :avoid_ssl, *options
  end
  def avoid_ssl
    if (!request.ssl? || ENV['RAILS_ENV'] == 'development')
      true
    else
      redirect_to(params.merge(:protocol => 'http://'))
      false
    end
  end

  include GetText
  before_init_gettext :maybe_save_locale
  init_gettext 'noosfero'

  include NeedsProfile

  before_filter :detect_stuff_by_domain
  attr_reader :environment

  before_filter :load_terminology

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    verify :method => :post, :only => actions, :redirect_to => redirect
  end

  protected

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

  def load_terminology
    # cache terminology for performance
    @@terminology_cache ||= {}
    @@terminology_cache[environment.id] ||= environment.terminology
    Noosfero.terminology = @@terminology_cache[environment.id]
  end

  def render_not_found(path = nil)
    @no_design_blocks = true
    @path ||= request.path
    render :template => 'shared/not_found.rhtml', :status => 404
  end

  def render_access_denied(message = nil)
    @no_design_blocks = true
    @message = message
    render :template => 'shared/access_denied.rhtml', :status => 403
  end

  def user
    current_user.person if logged_in?
  end

  def maybe_save_locale
    if params[:lang]
      cookies[:lang] = params[:lang]
    end
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
