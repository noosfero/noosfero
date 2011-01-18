class TasksController < MyProfileController

  protect 'perform_task', :profile
  
  def index
    @tasks = profile.all_pending_tasks.sort_by(&:created_at)
    @failed = params ? params[:failed] : {}
  end

  def processed
    @tasks = profile.all_finished_tasks.sort_by(&:created_at)
  end

  VALID_DECISIONS = [ 'finish', 'cancel', 'skip' ]

  def close
    failed = {}

    params[:tasks].each do |id, value|
      decision = value[:decision]
      if request.post? && VALID_DECISIONS.include?(decision) && id && decision != 'skip'
        task = profile.find_in_all_tasks(id)
        task.update_attributes!(value[:task])
        begin
          task.send(decision)
        rescue Exception => ex
          message = "#{task.title} (#{task.requestor ? task.requestor.name : task.author_name})"
          failed[ex.clean_message] ? failed[ex.clean_message] << message : failed[ex.clean_message] = [message]
        end
      end
    end

    if failed.blank?
      session[:notice] = _("All decisions were applied successfully.")
    else
      session[:notice] = _("Some tasks couldn't be applied.")
    end
    redirect_to params.merge!(:action => 'index', :failed => failed)
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
