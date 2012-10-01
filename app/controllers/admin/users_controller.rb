class UsersController < AdminController

  protect 'manage_environment_users', :environment

  def index
    respond_to do |format|
      format.html
      format.xml do
        @users = User.find(:all, :conditions => {:environment_id => environment.id}, :include => [:person])
        send_data @users.to_xml(
            :skip_types => true,
            :only => %w[email login created_at updated_at],
            :include => { :person => {:only => %w[name updated_at created_at address birth_date contact_phone identifier lat lng] } }),
          :type => 'text/xml',
          :disposition => "attachment; filename=users.xml"
      end
      format.csv do
        @users = User.find(:all, :conditions => {:environment_id => environment.id}, :include => [:person])
        render :template => "users/index_csv.rhtml", :content_type => 'text/csv', :layout => false
      end
    end
  end

  def send_mail
    @mailing = environment.mailings.build(params[:mailing])
    if request.post?
      @mailing.locale = locale
      @mailing.person = user
      if @mailing.save
        session[:notice] = _('The e-mails are being sent')
        redirect_to :action => 'index'
      else
        session[:notice] = _('Could not create the e-mail')
      end
    end
  end

end
