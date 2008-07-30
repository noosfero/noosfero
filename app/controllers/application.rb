# his is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

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
  module UsesDesignBlocksHelper
    def uses_design_blocks?
      @controller.uses_design_blocks?
    end
  end
  helper UsesDesignBlocksHelper

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include PermissionCheck

  before_init_gettext :maybe_save_locale
  after_init_gettext :check_locale
  init_gettext 'noosfero'

  include NeedsProfile

  before_filter :detect_stuff_by_domain
  attr_reader :environment

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    verify :method => :post, :only => actions, :redirect_to => redirect
  end

  # Fix some problems with Single Table Inheritance
  require_dependency 'textile_article'
  require_dependency 'tiny_mce_article'
  require_dependency 'text_article'
  require_dependency 'article'

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

  def render_not_found(path = nil)
    @path ||= request.path
#    raise "#{@path} not found"
    render(:file => File.join(RAILS_ROOT, 'app', 'views', 'shared', 'not_found.rhtml'), :layout => 'not_found', :status => 404)
  end

  def user
    current_user.person if logged_in?
  end

  def maybe_save_locale
    # save locale if forced
    if params[:lang]
      cookies[:lang] = params[:lang]
    end
    # force GetText to load a matching locale
    GetText.locale = nil
  end

  def check_locale
    available_locales = Noosfero.available_locales

    # do not accept unsupported locales
    if !available_locales.include?(locale.to_s)
      old_locale = locale.to_s
      # find a similar locale
      similar = available_locales.find { |loc| locale.to_s.split('_').first == loc.split('_').first }
      if similar
        set_locale similar
        cookies[:lang] = similar
      else
        # no similar locale, fallback to default
        set_locale(Noosfero.default_locale)
        cookies[:lang] = Noosfero.default_locale
      end
      RAILS_DEFAULT_LOGGER.info('Locale reverted from %s to %s' % [old_locale, locale])
    end

    # now set the system locale
    system_locale = '%s.utf8' % locale
    begin
      Locale.setlocale(Locale::LC_TIME, system_locale)
    rescue Exception => e
      # fallback to C
      RAILS_DEFAULT_LOGGER.info("Locale #{system_locale} not available, falling back to the portable \"C\" locale (consider installing the #{system_locale} locale in your system)")
      Locale.setlocale(Locale::LC_TIME, 'C')
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
