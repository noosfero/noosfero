require 'csv'

class CustomFormsPluginMyprofileController < MyProfileController
  protect 'post_content', :profile

  def index
    @forms = CustomFormsPlugin::Form.from_profile(profile)
  end

  def new
    @form = CustomFormsPlugin::Form.new

    respond_to do |format|
      format.html
    end
  end

  def create
    params[:form][:profile_id] = profile.id
    uploaded_data = params[:form].delete(:image)
    @form = CustomFormsPlugin::Form.new(params[:form])
    normalize_positions(@form)

    form_with_image  = add_gallery_in_form(@form, profile, uploaded_data)

    respond_to do |format|
      if form_with_image
        flash[:notice] = _("Custom form %s was successfully created.") % @form.name
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
    @form.attributes = params[:form]

    normalize_positions(@form)

    respond_to do |format|
      if @form.save
        flash[:notice] = _("Custom form %s was successfully updated.") % @form.name
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
    @sort_by = params[:sort_by] == 'author_name' ? 'author_name' : 'created_at'
    @submissions = @form.submissions.order(@sort_by)

    respond_to do |format|
      format.html
      format.csv do
        # CSV contains form fields, timestamp, user name and user email
        columns = @form.fields.count + 3
        csv_content = CSV.generate_line(['Timestamp', 'Name', 'Email'] + @form.fields.map(&:name))
        @submissions.each do |s|
          fields = [s.updated_at.strftime('%Y/%m/%d %T %Z'), s.profile.present? ? s.profile.name : s.author_name, s.profile.present? ? s.profile.email : s.author_email]
          @form.fields.each do |f|
            fields << s.answers.select{|a| a.field == f}.map{|answer| answer.to_s}
          end
          fields = fields.flatten
          csv_content << CSV.generate_line(fields + (columns - fields.size).times.map{""})
        end
        send_data csv_content, :type => 'text/csv', :filename => "#{@form.name}.csv"
      end
    end
  end

  def show_submission
    @submission = CustomFormsPlugin::Submission.find(params[:id])
    @form = @submission.form
  end

  def pending
    @form = CustomFormsPlugin::Form.find(params[:id])
    @pendings = CustomFormsPlugin::AdmissionSurvey.from_profile(@form.profile).pending.select {|task| task.form_id == @form.id}.map {|a| {:profile => a.target, :time => a.created_at} }

    @sort_by = params[:sort_by]
    @pendings = @pendings.sort_by { |s| s[:profile].name } if @sort_by == 'user'
  end

  private

  def normalize_positions(form)
    counter = 0
    form.fields.sort_by{ |f| f.position.to_i }.each do |field|
      field.position = counter
      counter += 1
    end
    form.fields.each do |field|
      counter = 0
      field.alternatives.sort_by{ |alt| alt.position.to_i }.each do |alt|
        alt.position = counter
        counter += 1
      end
    end
  end

  def add_gallery_in_form(form, profile, data)
    return form.save unless data
    form_image = UploadedFile.new(
      :uploaded_data => data,
      :profile => profile,
      :parent => nil,
    )

    form_settings = Noosfero::Plugin::Settings.new(profile, CustomFormsPlugin)
    form_gallery = Gallery.where(id: form_settings.gallery_id).first
    unless form_gallery
      form_gallery = Gallery.new(profile: profile, name: _("Query Gallery"))
    end

    form_gallery.images << form_image
    @form.image = form_image
    form_with_image = @form.save && form_gallery.save
    @form.errors.messages.merge!(form_gallery.errors.messages)
    form_with_image
  end
end
