class MapsController < MyProfileController

  protect 'edit_profile', :profile

  def edit_location
    @profile_data = profile
    if request.post?
      begin
        country = params[:profile_data][:country]
        city = params[:profile_data][:city]
        state = params[:profile_data][:state]
        nregion = NationalRegion.validate!(city, state, country)
        unless nregion.blank?
          params[:profile_data][:national_region_code] = nregion.national_region_code
        end

        Profile.transaction do
          if profile.update!(params[:profile_data])
            BlockSweeper.expire_blocks profile.blocks.select{ |b| b.class == LocationBlock }
            session[:notice] = _('Address was updated successfully!')
            redirect_to :action => 'edit_location'
          end
        end
      rescue Exception => exc
        flash[:error] = exc.message
      end
    end
  end

  def google_map
    render :partial => 'google_map.js'
  end

  def search_city
    render :json => MapsHelper.search_city(params[:term])
  end

  def search_state
    render :json => MapsHelper.search_state(params[:term])
  end

end
