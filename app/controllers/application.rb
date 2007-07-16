# This is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

  before_filter :detect_stuff_by_domain
  attr_reader :virtual_community

  uses_manage_template :edit => false

  before_filter :load_boxes
  #TODO To diplay the content we need a variable called '@boxes'. 
  #This variable is a set of boxes belongs to a owner
  #We have to see a better way to do that
  def load_boxes
    if Profile.exists?(1)
      owner = Profile.find(1) 
      @boxes = owner.boxes 
    end
  end

  before_filter :load_template
  # Load the template belongs to a Profile and set it at @chosen_template variable.
  # If no profile exist the @chosen_template variable is set to 'default'
  def load_template
    if Profile.exists?(1)
      @owner = Profile.find(1) 
    end
    @chosen_template = @owner.nil? ? "default" : @owner.template
  end

  def set_default_template
    p = Profile.find(params[:object_id])
    set_template(p,params[:template_name])
  end 

  private

  def set_template(object, template_name)
    object.template = template_name
    object.save
  end

  protected

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

end
