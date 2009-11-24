class TasksController < MyProfileController

  protect 'perform_task', :profile
  
  def index
    @tasks = profile.all_pending_tasks
  end

  def processed
    @tasks = profile.all_finished_tasks
  end

  VALID_DECISIONS = [ 'finish', 'cancel' ]

  def close
    decision = params[:decision]
    if request.post? && VALID_DECISIONS.include?(decision) && params[:id]
      task = profile.find_in_all_tasks(params[:id])
      task.update_attributes!(params[:task])
      begin
        task.send(decision)
      rescue Exception => ex
        flash[:notice] = ex.clean_message
      end
    end
    redirect_to :action => 'index'
  end

  def new
    @ticket = Ticket.new(params[:ticket])
    if params[:target_id]
      @ticket.target = profile.friends.find(params[:target_id])
    end
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
