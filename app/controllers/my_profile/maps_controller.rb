class MapsController < MyProfileController

  protect 'edit_profile', :profile

  def edit_location
    @profile_data = profile
    if request.post?
      begin
        national_code = nil
        country  = params[:profile_data][:country]
        city  = params[:profile_data][:city]
        state  = params[:profile_data][:state]

        nregion = NationalRegion.validate!(city, state, country)

        if nregion != nil
          national_code = nregion.national_region_code
        end
        
        params[:profile_data]["national_region_code"] = national_code

        Profile.transaction do
          if profile.update_attributes!(params[:profile_data])
            session[:notice] = _('Address was updated successfully!')
            redirect_to :action => 'edit_location'
          end
        end
      rescue Exception => exc
        
        flash[:error] = exc.message

      end
    end
  end

  def search_city

    term = params[:term];

    regions = NationalRegion.search_city(term + "%", true).map {|r|{ :label => r.city , :category => r.state}}

    render :json => regions

  end

  def search_state

    term = params[:term];

    regions = NationalRegion.search_state(term + "%", true).map {|r|{ :label => r.state}}

    render :json => regions

  end

end
