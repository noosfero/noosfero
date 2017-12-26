class EnterpriseRegistrationController < ApplicationController


  before_filter :login_required

  def index
    @create_enterprise = CreateEnterprise.new(params[:create_enterprise])
    @create_enterprise.requestor = user
    @kinds = environment.kinds.where(:type => 'Enterprise')
    @validation = environment.organization_approval_method
    @create_enterprise.target = define_target(@validation)
    @regions = @create_enterprise.available_regions.map {|region| [region.name, region.id]} if @validation == :region
    if request.post?
      if @create_enterprise.valid?
        if @validation == :none
          render :action => :creation if creation(@create_enterprise)
        else
          render :action => :confirmation if @create_enterprise.save
        end
      elsif @validation == :region && @create_enterprise.valid_before_selecting_target?
        @validators = @create_enterprise.region.validators
        render :action => :select_validator
      end
    end
  end

  private

  def creation create_enterprise
      @enterprise = create_enterprise.target.profiles.find_by identifier: create_enterprise.identifier if create_enterprise.perform
  end

  def define_target(validation)
    if validation == :region
      if params[:create_enterprise] && params[:create_enterprise][:target_id]
        Profile.find(params[:create_enterprise][:target_id])
      end
    else validation == :admin || validation == :none
      environment
    end
  end

end
