class CommentClassificationPluginLabelsController < AdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def index
#    @labels = @environment.labels
    @labels = CommentClassificationPlugin::Label.all
  end

  def create
    @label = CommentClassificationPlugin::Label.new(params[:label])
    @colors = CommentClassificationPlugin::Label::COLORS
    if request.post?
      begin
        @label.owner = environment
        @label.save!
        session[:notice] = _('Label created')
        redirect_to :action => 'index'
      rescue
        session[:notice] = _('Label could not be created')
      end
    end
  end

  def edit
#    @labels = @environment.labels.find(params[:id])
    @label = CommentClassificationPlugin::Label.find(params[:id])
    @colors = CommentClassificationPlugin::Label::COLORS
    if request.post?
      begin
        @label.update!(params[:label])
        session[:notice] = _('Label updated')
        redirect_to :action => :index
      rescue
        session[:notice] = _('Failed to edit label')
      end
    end
  end

  def remove
#    @label = environment.labels.find(params[:label])
    @label = CommentClassificationPlugin::Label.find(params[:id])
    if request.post?
      begin
        @label.destroy
        session[:notice] = _('Label removed')
      rescue
        session[:notice] = _('Label could not be removed')
      end
    else
      session[:notice] = _('Label could not be removed')
    end
    redirect_to :action => 'index'
  end

end
