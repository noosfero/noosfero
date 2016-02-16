class CommentClassificationPluginStatusController < AdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def index
#    @labels = @environment.labels
    @status = CommentClassificationPlugin::Status.all
  end

  def create
    @status = CommentClassificationPlugin::Status.new(params[:status])
    if request.post?
      begin
        @status.owner = environment
        @status.save!
        session[:notice] = _('Status created')
        redirect_to :action => 'index'
      rescue
        session[:notice] = _('Status could not be created')
      end
    end
  end

  def edit
#    @labels = @environment.labels.find(params[:id])
    @status = CommentClassificationPlugin::Status.find(params[:id])
    if request.post?
      begin
        @status.update!(params[:status])
        session[:notice] = _('Status updated')
        redirect_to :action => :index
      rescue
        session[:notice] = _('Failed to edit status')
      end
    end
  end

  def remove
#    @label = environment.labels.find(params[:label])
    @status = CommentClassificationPlugin::Status.find(params[:id])
    if request.post?
      begin
        @status.destroy
        session[:notice] = _('Status removed')
      rescue
        session[:notice] = _('Status could not be removed')
      end
    else
      session[:notice] = _('Status could not be removed')
    end
    redirect_to :action => 'index'
  end

end
