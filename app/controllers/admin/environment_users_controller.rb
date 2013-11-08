class EnvironmentUsersController < AdminController

  protect 'manage_environment_users', :environment

  def per_page
    10
  end

  def index
    @q = params[:q]
    if @q.blank?
      @collection = environment.people.no_templates(environment).paginate(
        :per_page => per_page,
        :page => params[:npage]
      )
    else
      @collection = find_by_contents(:people, environment.people.no_templates(environment), @q, {:per_page => per_page, :page => params[:npage]})[:results]
    end
  end

  def set_admin_role
    @person = environment.people.find(params[:id])
    environment.add_admin(@person)
    redirect_to :action => :index, :q => params[:q]
  end

  def reset_admin_role
    @person = environment.people.find(params[:id])
    environment.remove_admin(@person)
    redirect_to :action => :index, :q => params[:q]
  end

  def activate
    @person = environment.people.find(params[:id])
    @person.user.activate
    redirect_to :action => :index, :q => params[:q]
  end

  def deactivate
    @person = environment.people.find(params[:id])
    @person.user.deactivate
    redirect_to :action => :index, :q => params[:q]
  end
end
