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
  module UsesDesignBlocksHelper
    def uses_design_blocks?
      ! self.class.instance_variable_get('@no_design_blocks')
    end
  end
  helper UsesDesignBlocksHelper
  include UsesDesignBlocksHelper

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include PermissionCheck

  init_gettext 'noosfero'
  before_init_gettext :force_language
  after_init_gettext :set_system_locale

  include NeedsProfile

  before_filter :detect_stuff_by_domain
  attr_reader :environment

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

  def render_not_found(path = nil)
    @path ||= request.path
#    raise "#{@path} not found"
    render(:file => File.join(RAILS_ROOT, 'app', 'views', 'shared', 'not_found.rhtml'), :layout => 'not_found', :status => 404)
  end

  def user
    current_user.person if logged_in?
  end

  def force_language
    lang = params[:lang]
    if lang.blank?
      # no language forced, get language from cookie
      lang = cookies[:lang] || Noosfero.default_locale
    else
      # save forced language in the cookie
      cookies[:lang] = lang
    end

    unless lang.blank?
      set_locale lang
    end
  end

  def set_system_locale
    # don't allow unsupported locales
    available_locales = Noosfero.locales.keys
    if !available_locales.include?(GetText.locale.to_s)
      # guess similar locales by using same language
      similar = available_locales.find { |loc| GetText.locale.to_s.split('_').first == loc.split('_').first }
      if similar
        set_locale similar
      else
        set_locale(Noosfero.default_locale || 'en')
      end
    end

    # actually set the system locale
    lang = GetText.locale.to_s
    system_locale =
      if (lang == 'en') || lang.blank?
        'C'
      else
        ('%s.utf8' % lang)
      end
    Locale.setlocale(Locale::LC_ALL, system_locale)
  end

end
