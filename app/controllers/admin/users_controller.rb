require 'csv'

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
        # using a direct connection with the dbms to optimize
        command = User.send(:sanitize_sql, ["SELECT profiles.name, users.email FROM profiles
                                             INNER JOIN users ON profiles.user_id=users.id
                                             WHERE profiles.environment_id = ?", environment.id])
        users = User.connection.execute(command)
        csv_content = "name;email\n"
        users.each { |u|
          CSV.generate_row([u['name'], u['email']], 2, csv_content, fs=';')
        }
        render :text => csv_content, :content_type => 'text/csv', :layout => false
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
