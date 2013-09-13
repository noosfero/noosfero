class CustomFormsPluginMyprofileController < MyProfileController
  protect 'post_content', :profile

  def index
    @forms = CustomFormsPlugin::Form.from(profile)
  end

  def new
    @form = CustomFormsPlugin::Form.new

    respond_to do |format|
      format.html
    end
  end

  def create
    params[:form][:profile_id] = profile.id
    @form = CustomFormsPlugin::Form.new(params[:form])

    respond_to do |format|
      if @form.save
        flash[:notice] = _("Custom form #{@form.name} was successfully created.")
        format.html { redirect_to(:action=>'index') }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @form = CustomFormsPlugin::Form.find(params[:id])
  end

  def update
    @form = CustomFormsPlugin::Form.find(params[:id])

    respond_to do |format|
      if @form.update_attributes(params[:form])
        flash[:notice] = _("Custom form #{@form.name} was successfully updated.")
        format.html { redirect_to(:action=>'index') }
      else
        session['notice'] = _('Form could not be updated')
        format.html { render :action => 'edit' }
      end
    end
  end

  def remove
    @form = CustomFormsPlugin::Form.find(params[:id])
    begin
      @form.destroy
      session[:notice] = _('Form removed')
    rescue
      session[:notice] = _('Form could not be removed')
    end
    redirect_to :action => 'index'
  end

  def submissions
    @form = CustomFormsPlugin::Form.find(params[:id])
    @submissions = @form.submissions
  end

  def show_submission
    @submission = CustomFormsPlugin::Submission.find(params[:id])
    @form = @submission.form
  end

end
