# This is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

  ICONS_DIR_PATH = "#{RAILS_ROOT}/public/icons"
  THEME_DIR_PATH = "#{RAILS_ROOT}/public/themes"


  before_filter :detect_stuff_by_domain
  attr_reader :virtual_community


  before_filter :load_owner
  # Load the owner 
  def load_owner
    # TODO: this should not be hardcoded
    if Profile.exists?(1)
      @owner = Profile.find(1) 
    end
  end

  before_filter :load_icons_theme
  # Load the icons belongs to a Profile and set it at @chosen_icons_theme variable.
  # If no profile exist the @chosen_icons_theme variable is set to 'default'
  def load_icons_theme
    if Profile.exists?(1)
      @owner = Profile.find(1) 
    end
    @chosen_icons_theme = @owner.icons_theme.nil? ? "default" : @owner.icons_theme
  end


  # Set the default template to the profile
  def set_default_template
    p = Profile.find(params[:object_id])
    set_template(p,params[:template_name])
  end 

  # Set the default theme to the profile
  def set_default_theme
    p = Profile.find(params[:object_id])
    set_theme(p,params[:theme_name])
  end 

  # Set the default icons theme to the profile
  def set_default_icons_theme
    p = Profile.find(params[:object_id])
    set_icons_theme(p,params[:icons_theme_name])
  end 


  private

  # Set to the owner the theme choosed
  def set_theme(object, theme_name)
    object.theme = theme_name
    object.save
  end

  # Set to the owner the icons theme choosed
  def set_icons_theme(object,icons_theme_name)
    object.icons_theme = icons_theme_name
    object.save
  end

  protected

  # TODO: move this logic somewhere else (Domain class?)
  def detect_stuff_by_domain
    @domain = Domain.find_by_name(request.host)
    if @domain.nil?
      @virtual_community = VirtualCommunity.default
    else
      @virtual_community = @domain.virtual_community
      @profile = @domain.profile
    end
  end

  def self.acts_as_virtual_community_admin_controller
    before_filter :load_admin_controller
    layout 'virtual_community_admin'
  end
  def load_admin_controller
    # TODO: check access control
  end

  # declares that the given <tt>actions</tt> cannot be accessed by other HTTP
  # method besides POST.
  def self.post_only(actions, redirect = { :action => 'index'})
    verify :method => :post, :only => actions, :redirect_to => redirect
  end

end
