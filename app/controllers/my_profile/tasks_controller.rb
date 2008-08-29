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
    target = profile.friends.find_by_id(params[:target_id])
    @ticket = Ticket.new(params[:ticket])
    @ticket.target = target
    @ticket.requestor = profile
    if request.post?
      if @ticket.save
        redirect_to :action => 'index'
      end
    end
  end

  def list_requested
    @tasks = Task.find_all_by_requestor_id(profile.id)
  end

  def ticket_details
    @ticket = Ticket.find(:first, :conditions => ['(requestor_id = ? or target_id = ?) and id = ?', profile.id, profile.id, params[:id]])
  end

end
