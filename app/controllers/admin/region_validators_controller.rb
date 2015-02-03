class RegionValidatorsController < AdminController

  before_filter :load_region_and_search, :except => 'index'

  protect 'manage_environment_validators', :environment

  def index
    @regions = Region.top_level_for(environment)
  end

  def region
    # nothing to do, load_region_and_search already does everything needed here 
  end

  def search
    render :partial => 'search'
  end

  def add
    validator = environment.organizations.find(params[:validator_id])
    @region.validators << validator
    redirect_to :action => 'region', :id => @region.id
  end

  def remove
    validator = environment.organizations.find(params[:validator_id])
    @region.validators.delete(validator)
    redirect_to :action => 'region', :id => @region.id
  end

  protected

  def load_region_and_search
    @region = environment.regions.find(params[:id])
    if params[:search]
      @search = find_by_contents(:organizations, environment, Organization, params[:search])[:results].reject {|item| @region.validator_ids.include?(item.id) }
    end
  end

end
