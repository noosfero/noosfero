# This is the application's main controller. Features defined here are
# available in all controllers.
class ApplicationController < ActionController::Base

  TEMPLATE_DIR_PATH = 'public/templates'
  ICON_DIR_PATH = 'public/icons'

  before_filter :detect_stuff_by_domain
  attr_reader :virtual_community

  uses_manage_template :edit => false

  before_filter :load_template
  # Load the template belongs to a Profile and set it at @chosen_template variable.
  # If no profile exist the @chosen_template variable is set to 'default'
  def load_template
    if Profile.exists?(1)
      @owner = Profile.find(1) 
    end
    @chosen_template = @owner.nil? ? "default" : @owner.template
  end

  before_filter :load_boxes
  #Load a set of boxes belongs to a owner. We have to situations.
  #  1 - The owner has equal or more boxes that boxes defined in template.
  #      The system limit the max number of boxes to the number permited in template
  #  2 - The owner there isn't enough box that defined in template
  #      The system create the boxes needed to use the current template
  def load_boxes
    raise _('Template not found') if @chosen_template.nil?
    n = boxes_by_template(@chosen_template)
    @boxes = Array.new
    if Profile.exists?(1)
      owner = Profile.find(1)
      @boxes = owner.boxes 
    end

    if @boxes.length >= n
      @boxes = @boxes.first(n) 
    else
      @boxes = @boxes    
    end

  end

  def boxes_by_template(template)
    f = YAML.load_file("#{RAILS_ROOT}/public/templates/default/default.yml")
    number_of_boxes = f[template.to_s]["number_of_boxes"]
    raise _("The file #{template}.yml it's not a valid template filename") if number_of_boxes.nil?
    number_of_boxes
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

end
