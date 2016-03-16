class OrganizationsController < AdminController

  protect 'manage_environment_organizations', :environment

  def index
    @filter = params[:filter] || 'any'
    @title = _('Organization profiles')
    @type = params[:type] || "any"
    @types_filter = [[_('All'), 'any'], [_('Community'), 'Community'], [_('Enterprise'), 'Enterprise']]
    @plugins.dispatch_without_flatten(:organization_types_filter_options).each do |plugin_response|
      @types_filter = @types_filter | plugin_response
    end
    @types_hash = {}
    @types_filter.each{|list| @types_hash[list.last] = list.first}

    scope = @plugins.dispatch_first(:filter_manage_organization_scope, @type)
    if scope.blank?
      scope = environment.organizations
      scope = scope.where(:type => @type) if @type != 'any'
    end

    if @filter == 'enabled'
      scope = scope.visible
    elsif @filter == 'disabled'
      scope = scope.disabled
    end

    scope = scope.order('name ASC')

    @q = params[:q]
    @collection = find_by_contents(:organizations, environment, scope, @q, {:per_page => per_page, :page => params[:npage]})[:results]
  end

  def activate
    organization = environment.organizations.find(params[:id])
    if organization.enable
      render :text => (_('%s enabled') % organization.name).to_json
    else
      render :text => (_('%s could not be enabled') % organization.name).to_json
    end
  end

  def deactivate
    organization = environment.organizations.find(params[:id])
    if organization.disable
      render :text => (_('%s disabled') % organization.name).to_json
    else
      render :text => (_('%s could not be disable') % organization.name).to_json
    end
  end

  def destroy
    if request.post?
      organization = environment.organizations.find(params[:id])
      if organization && organization.destroy
        render :text => (_('%s removed') % organization.name).to_json
      else
        render :text => (_('%s could not be removed') % organization.name).to_json
      end
    else
      render :nothing => true
    end
  end

  private

  def per_page
    10
  end
end
