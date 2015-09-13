class CommentClassificationPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  before_filter :organizations_only
  protect 'moderate_comments', :profile

  def index
    @comments = Comment.all
  end

  def add_status
    @comment = Comment.find(params[:id])
    @statuses = CommentClassificationPlugin::Status.enabled
    @status = CommentClassificationPlugin::CommentStatusUser.new(:profile => user, :comment => @comment)
    if request.post? && params[:status]
      @status.update(params[:status])
      @status.save
    end
  end

  private

  def organizations_only
    render_not_found if !profile.organization?
  end
end
