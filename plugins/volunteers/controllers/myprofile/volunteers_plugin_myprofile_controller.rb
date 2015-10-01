class VolunteersPluginMyprofileController < MyProfileController

  no_design_blocks

  # remove fake dependency
  helper OrdersPlugin::DateHelper

  def index

  end

  def toggle_assign
    @owner_id = params[:owner_id]
    @owner_type = params[:owner_type]
    @owner = @owner_type.constantize.find @owner_id
    @period = @owner.volunteers_periods.find params[:id]

    if profile.members.include? user
      @assignment = @period.assignments.where(profile_id: user.id).first
      if @assignment
        @assignment.destroy
      else
        @period.assignments.create! profile_id: user.id
      end
      @period.assignments.reload
    end

    render partial: 'volunteering', locals: {period: @period}
  end

  protected

end
