require 'noosfero/multi_tenancy'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_multitenancy
  before_filter :detect_stuff_by_domain
  before_filter :init_noosfero_plugins
  before_filter :allow_cross_domain_access

  def allow_cross_domain_access
    origin = request.headers['Origin']
    return if origin.blank?
    if environment.access_control_allow_origin.include? origin
      response.headers["Access-Control-Allow-Origin"] = origin
      unless environment.access_control_allow_methods.blank?
        response.headers["Access-Control-Allow-Methods"] = environment.access_control_allow_methods
      end
    elsif environment.restrict_to_access_control_origins
      render_access_denied _('Origin not in allowed.')
    end
  end

  include ApplicationHelper
  layout :get_layout
  def get_layout
    return nil if request.format == :js or request.xhr?

    theme_layout = theme_option(:layout)
    if theme_layout
      theme_view_file('layouts/'+theme_layout) || theme_layout
    else
     'application'
    end
  end

  def log_processing
    super
    return unless Rails.env == 'production'
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
    I18n.default_locale = FastGettext.default_locale
    if params[:lang]
      session[:lang] = params[:lang]
    end
  end

  include NeedsProfile

  attr_reader :environment

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    before_filter(:only => actions) do |controller|
      if !controller.request.post?
        controller.redirect_to redirect
      end
    end
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
        @environment = Environment.new
        @environment.name = "Noosfero"
        @environment.is_default = true
        @environment.save!
      end
    else
      @environment = @domain.environment
      @profile = @domain.profile

      # Check if the requested profile belongs to another domain
      if @profile && !params[:profile].blank? && params[:profile] != @profile.identifier
        @profile = @environment.profiles.find_by_identifier params[:profile]
        redirect_to params.merge(:host => @profile.default_hostname)
      end
    end
  end

  include Noosfero::Plugin::HotSpot

  # FIXME this filter just loads @plugins to children controllers and helpers
  def init_noosfero_plugins
    plugins
  end

  def render_not_found(path = nil)
    @no_design_blocks = true
    @path ||= request.path
    render :template => 'shared/not_found.html.erb', :status => 404, :layout => get_layout
  end
  alias :render_404 :render_not_found

  def render_access_denied(message = nil, title = nil)
    @no_design_blocks = true
    @message = message
    @title = title
    render :template => 'shared/access_denied.html.erb', :status => 403
  end

  def load_category
    unless params[:category_path].blank?
      path = params[:category_path]
      @category = environment.categories.find_by_path(path)
      if @category.nil?
        render_not_found(path)
      end
    end
  end

  def find_by_contents(asset, scope, query, paginate_options={:page => 1}, options={})
    plugins.dispatch_first(:find_by_contents, asset, scope, query, paginate_options, options) ||
    fallback_find_by_contents(asset, scope, query, paginate_options, options)
  end

  private

  def fallback_find_by_contents(asset, scope, query, paginate_options, options)
    scope = scope.like_search(query) unless query.blank?
    scope = scope.send(options[:filter]) unless options[:filter].blank?
    {:results => scope.paginate(paginate_options)}
  end

end
