class TasksController < MyProfileController

  def index
    @tasks = profile.tasks.pending
  end

  def processed
    @tasks = profile.tasks.finished
  end

  VALID_DECISIONS = [ 'finish', 'cancel' ]

  def close
    decision = params[:decision]
    if request.post? && VALID_DECISIONS.include?(decision) && params[:id]
      task = Task.find(params[:id])
      task.update_attributes!(params[:task])
      task.send(decision)
    end
    redirect_to :action => 'index'
  end

end
