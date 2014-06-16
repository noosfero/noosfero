class SubOrganizationsPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  before_filter :organizations_only
  protect 'edit_profile', :profile

  def index
    @children = Organization.children(profile)
    @tokenized_children = prepare_to_token_input(@children)
    @pending_children = Organization.pending_children(profile)
    if request.post?
      begin
        original = Organization.children(profile)
        requested = Organization.find(params[:q].split(','))
        added = requested - original
        removed = original - requested
        added.each do |organization|
          if current_person.has_permission?('perform_task',organization)
            SubOrganizationsPlugin::Relation.add_children(profile, organization)
          else
            SubOrganizationsPlugin::ApprovePaternity.create!(:requestor => user, :temp_parent_type => profile.class.name, :temp_parent_id => profile.id, :target => organization)
          end
        end
        SubOrganizationsPlugin::Relation.remove_children(profile,removed)
        session[:notice] = _('Sub-organizations updated')
      rescue Exception => exception
        logger.error(exception.to_s)
        session[:notice] = _('Sub-organizations could not be updated')
      end
      redirect_to :action => :index
    end
  end

  def search_organization
    render :text => prepare_to_token_input(environment.organizations.find(:all, :conditions =>
      ["(LOWER(name) LIKE ? OR LOWER(identifier) LIKE ?)
        AND (identifier NOT LIKE ?) AND (id != ?)",
        "%#{params[:q]}%", "%#{params[:q]}%", "%_template", profile.id]).
      select { |organization|
        Organization.children(organization).blank? &&
        !Organization.pending_children(profile).include?(organization)
      }).to_json
  end

  private

  def organizations_only
    render_not_found if !profile.organization?
  end

  def prepare_to_token_input(array)
    array.map { |object| {:id => object.id, :name => object.name} }
  end
end
