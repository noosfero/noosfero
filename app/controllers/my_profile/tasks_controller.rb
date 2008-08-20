class TasksController < MyProfileController

  protect 'perform_task', :profile
  
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
      task = profile.tasks.find(params[:id])
      task.update_attributes!(params[:task])
      task.send(decision)
    end
    redirect_to :action => 'index'
  end

  def new
    @ticket = Ticket.new(params[:ticket])
    @ticket.requestor = profile
    if request.post?
      @ticket.save!
      redirect_to :action => 'index'
    end
  end

end
