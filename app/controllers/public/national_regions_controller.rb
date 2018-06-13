class NationalRegionsController < ApplicationController
  def cities
    unless params[:state_code]
      head :bad_request
      return
    end

    cities = NationalRegion.cities
                           .with_parent(params[:state_code])
                           .order(:name)
                           .pluck(:name, :national_region_code)
    render json: { cities: cities }
  end

  def states
    unless params[:country_code]
      head :bad_request
      return
    end

    states = NationalRegion.states
                           .with_parent(params[:country_code])
                           .order(:name)
                           .pluck(:name, :national_region_code)
    render json: { states: states }
  end
end
