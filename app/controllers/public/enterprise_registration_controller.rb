class EnterpriseRegistrationController < ApplicationController


  before_filter :login_required

  # Just go to the first step.
  #
  # FIXME: shouldn't this action present some sort of welcome message and point
  # to the first step explicitly?
  def index
    @validation = environment.organization_approval_method
    @create_enterprise = CreateEnterprise.new(params[:create_enterprise])
    if @validation == :region
      if params[:create_enterprise] && params[:create_enterprise][:target_id]
        @create_enterprise.target = Profile.find(params[:create_enterprise][:target_id])
      end
    elsif @validation == :admin || @validation == :none
      @create_enterprise.target = environment
    end
    @create_enterprise.requestor = user
    the_action =
      if request.post?
        if @create_enterprise.valid_before_selecting_target?
          if @create_enterprise.valid? && @validation == :none
            :creation
          elsif @create_enterprise.valid? || @validation == :admin
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
    if @validation == :region
      @regions = @create_enterprise.available_regions.map {|region| [region.name, region.id]}
    end
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

  # Records the enterprise and presents a confirmation message
  # saying to the user that the enterprise was created.
  def creation
    @create_enterprise.perform
    @enterprise = @create_enterprise.target.profiles.find_by_identifier(@create_enterprise.identifier)
  end

end
