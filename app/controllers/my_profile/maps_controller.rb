class MapsController < MyProfileController

  skip_before_action :verify_authenticity_token, only: [:google_map]
  include CategoriesHelper

  protect 'edit_profile', :profile

  def edit_location
    @profile_data = profile
    if request.post?
      begin
        profile.assign_attributes(params[:profile_data])
        nregion = NationalRegion.validate!(profile.city, profile.state,
                                           profile.metadata['country'])
        unless nregion.blank?
          profile.national_region_code = nregion.national_region_code
        end

        Profile.transaction do
          if profile.save!
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

  def search_city
    render :json => MapsHelper.search_city(params[:term])
  end

  def search_state
    render :json => MapsHelper.search_state(params[:term])
  end

end
