class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile

  def index
    @pending_tasks = profile.all_pending_tasks.select{|i| user.has_permission?(i.permission, profile)}
  end

  helper :profile

  # edits the profile info (posts back)
  def edit
    @profile_data = profile
    @possible_domains = profile.possible_domains
    if request.post?
      begin
        Profile.transaction do
        Image.transaction do
          if profile.update_attributes!(params[:profile_data])
            redirect_to :action => 'index', :profile => profile.identifier
          end
        end
        end
      rescue
        if profile.identifier.blank?
          profile.identifier = params[:profile]
        end
        session[:notice] = _('Cannot update profile')
      end
    end
  end

  def enable
    @to_enable = profile
    if request.post? && params[:confirmation]
      unless @to_enable.update_attribute('enabled', true)
        session[:notice] = _('%s was not enabled.') % @to_enable.name
      end
      redirect_to :action => 'index'
    end
  end

  def disable
    @to_disable = profile
    if request.post? && params[:confirmation]
      unless @to_disable.update_attribute('enabled', false)
        session[:notice] = _('%s was not disabled.') % @to_disable.name
      end
      redirect_to :action => 'index'
    end
  end

  def update_categories
    @object = profile
    if params[:category_id]
      @current_category = Category.find(params[:category_id])
      @categories = @current_category.children
    else
      @categories = environment.top_level_categories.select{|i| !i.children.empty?}
    end
    render :partial => 'shared/select_categories', :locals => {:object_name => 'profile_data', :multiple => true}, :layout => false
  end

  def header_footer
    @no_design_blocks = true
    if request.post?
      @profile.update_header_and_footer(params[:custom_header], params[:custom_footer])
      redirect_to :action => 'index'
    else
      @header = boxes_holder.custom_header
      @footer = boxes_holder.custom_footer
    end
  end

end
