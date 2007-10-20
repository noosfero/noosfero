class RegionValidatorsController < ApplicationController

  before_filter :load_region_and_search, :except => 'index'

#  protect [:index, :region, :search, :add, :remove], 'manage_environment_validators', :environment

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
      @search = @region.search_possible_validators(params[:search])
    end
  end

end
