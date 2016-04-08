class ToleranceTimePluginMyprofileController < MyProfileController
  def index
    @tolerance = ToleranceTimePlugin::Tolerance.find_by(profile_id: profile.id) || ToleranceTimePlugin::Tolerance.create!(:profile => profile)
    convert_values
    if request.post?
      begin
        convert_params
        @tolerance.update!(params[:tolerance])
        convert_values
        session[:notice] = _('Tolerance updated')
      rescue
        session[:notice] = _('Tolerance could not be updated')
      end
    end
  end

  private

  def convert_params
    params[:tolerance][:content_tolerance] = params[:tolerance][:content_tolerance].to_i * params[:content_tolerance_unit].to_i if !params[:tolerance][:content_tolerance].blank?
    params[:tolerance][:comment_tolerance] = params[:tolerance][:comment_tolerance].to_i * params[:comment_tolerance_unit].to_i if !params[:tolerance][:comment_tolerance].blank?
  end

  def convert_values
    @content_default_unit = select_unit(@tolerance.content_tolerance)
    @comment_default_unit = select_unit(@tolerance.comment_tolerance)
    @tolerance.content_tolerance /= @content_default_unit if !@tolerance.content_tolerance.nil?
    @tolerance.comment_tolerance /= @comment_default_unit if !@tolerance.comment_tolerance.nil?
  end

  def select_unit(value)
    return 1 if value.nil? || value == 0
    return 3600 if value % 3600 == 0
    return 60 if value % 60 == 0
    return 1
  end
end
