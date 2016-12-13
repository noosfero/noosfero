class KindsController < AdminController
  protect 'manage_environment_kinds', :environment

  def index
    @kinds = {}
    @kinds['Person'] = environment.kinds.where(:type => 'Person').order(:moderated)
    @kinds['Community'] = environment.kinds.where(:type => 'Community').order(:moderated)
    @kinds['Enterprise'] = environment.kinds.where(:type => 'Enterprise').order(:moderated)
  end

  def new
    @kind = Kind.new(params[:kind])
    if request.post?
      @kind.environment = environment
      if @kind.save
        session[:notice] = _('Kind successfully created')
        redirect_to :action => 'index'
      else
        session[:notice] = _('There were some problems creating this new kind')
      end
    end
  end

  def edit
    @kind = environment.kinds.find(params[:id])
    if request.post?
      if @kind.update_attributes(params[:kind])
        session[:notice] = _('Kind successfully updated')
        redirect_to :action => 'index'
      else
        session[:notice] = _('There were some problems editing this kind')
      end
    end
  end

  def destroy
    kind = environment.kinds.find(params[:id])
    if kind.present?
      if kind.destroy
        session[:notice] = _('Kind sucessfully removed')
      else
        session[:notice] = _('There were some problems deleting this kind')
      end
    end
    redirect_to :action => 'index'
  end
end
