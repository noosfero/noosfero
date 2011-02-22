class MezuroPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @projects = MezuroPlugin::Project.by_profile(profile)
  end

  def new
    @project = MezuroPlugin::Project.new
  end

  def create
    @project  = MezuroPlugin::Project.new(params[:project])
    if @project.save
      session[:notice] = _('Project successfully registered')
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @project = MezuroPlugin::Project.find(params[:id])
  end

  def update
    @project  = MezuroPlugin::Project.find(params[:id])
    if @project.update_attributes(params[:project])
      session[:notice] = _('Project successfully updated')
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def show
    @project = MezuroPlugin::Project.find_by_identifier params[:identifier]
    @total_metrics = @project.total_metrics if @project != nil
    @statistical_metrics = @project.statistical_metrics if @project != nil
    @svn_error = @project.svn_error if (@project != nil && @project.svn_error)
  end

  def destroy
    @project = MezuroPlugin::Project.by_profile(profile).find(params[:id])
    if request.post?
      if @project.destroy
        session[:notice] = _('Project successfully removed.')
      else
        session[:notice] = _('Project was not successfully removed.')
      end
      redirect_to :action => 'index'
    end
  end

end
