class TasksController < MyProfileController

  def index
    @tasks = profile.tasks.pending
  end

end
