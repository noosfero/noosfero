class SpamController < MyProfileController

  protect :moderate_comments, :profile

  def index
    if request.post?
      begin
        # FIXME duplicated logic
        #
        # This logic more or less replicates what is already in
        # ContentViewerController#view_page,
        # ContentViewerController#remove_comment and
        # ContentViewerController#mark_comment_as_spam
        if params[:remove_comment]
          profile.comments_received.find(params[:remove_comment]).destroy
        end
        if params[:remove_task]
          Task.to(profile).find_by(id: params[:remove_task]).destroy
        end
        if params[:mark_comment_as_ham]
          profile.comments_received.find(params[:mark_comment_as_ham]).ham!
        end
        if params[:mark_task_as_ham] && (t = Task.to(profile).find_by(id: params[:mark_task_as_ham]))
          t.ham!
        end
        if request.xhr?
          json_response(true)
        else
          redirect_to :action => :index
        end
      rescue
        json_response(false)
      end
      return
    end

    @comment_spam = profile.comments_received.spam.paginate({:page => params[:comments_page]})
    @task_spam = Task.to(profile).spam.paginate({:page => params[:tasks_page]})
  end

  protected

  def json_response(status)
    render :text => {'ok' => status }.to_json, :content_type => 'application/json'
  end

end
