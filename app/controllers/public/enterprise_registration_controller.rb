class EnterpriseRegistrationController < ApplicationController

  # Just go to the first step.
  # 
  # FIXME: shouldn't this action present some sort of welcome message and point
  # to the first step explicitly?
  def index
    @create_enterprise = CreateEnterprise.new(params[:create_enterprise])
    @create_enterprise.requestor = current_user.person
    the_action =
      if request.post?
        if @create_enterprise.valid_before_selecting_target?
          if @create_enterprise.valid?
            :confirmation
          else
            :select_validator
          end
        end
      end

    # default to basic_information
    the_action ||= :basic_information

    send(the_action)
    render :action => the_action
  end

  protected

  # Fill in the form and select your Region. 
  #
  # Posts back.
  def basic_information
    @regions = environment.regions.map {|item| [item.name, item.id]}
  end

  # present information about validator organizations, and the user one to
  # validate her brand new enterprise.
  #
  # Posts back.
  def select_validator
    @validators = @create_enterprise.region.validators
  end

  # Actually records the enterprise registration request and presents a
  # confirmation message saying to the user that the enterprise register
  # request was done.
  def confirmation
    @create_enterprise.save!
  end

end
