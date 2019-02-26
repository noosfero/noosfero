require 'csv'

class CustomFormsPluginMyprofileController < MyProfileController
  helper CustomFormsPlugin::Helper

  protect 'post_content', :profile

  before_action :remove_empty_alternatives, :only => [:create, :update]

  def index
    @forms = {}
    all_forms = CustomFormsPlugin::Form.from_profile(profile)
    CustomFormsPlugin::Form::KINDS.each do |kind|
      @forms[kind.to_sym] = all_forms.by_kind(kind)
    end
  end

  def new
    @form = CustomFormsPlugin::Form.new
    @kind = params[:kind]

    respond_to do |format|
      format.html
    end
  end

  def create
    params[:form][:profile_id] = profile.id
    uploaded_data = params[:form].delete(:image)
    should_remove_image = params[:form].delete(:remove_image)
    @form = CustomFormsPlugin::Form.new(params[:form])
    normalize_positions(@form)

    form_with_image = add_gallery_in_form(@form, profile,
                                          uploaded_data, should_remove_image)
    respond_to do |format|
      if form_with_image
        session[:notice] = _("%s was successfully created") % @form.name
        format.html { redirect_to(:action=>'index') }
      else
        @kind = @form.kind
        format.html { render :action => 'new'}
      end
    end
  end

  def edit
    @form = CustomFormsPlugin::Form.find(params[:id])
    @kind = @form.kind
  end

  def update
    @form = CustomFormsPlugin::Form.find(params[:id])
    uploaded_data = params[:form].delete(:image)
    should_remove_image = params[:form].delete(:remove_image)
    @form.attributes = params[:form]
    normalize_positions(@form)

    form_with_image = add_gallery_in_form(@form, profile,
                                          uploaded_data, should_remove_image)
    respond_to do |format|
      if form_with_image
        session[:notice] = _("%s was successfully updated") % @form.name
        format.html { redirect_to(:action=>'index') }
      else
        session['notice'] = _('The %s could not be updated') % _(params[:form][:kind])
        @kind = @form.kind
        format.html { render :action => 'edit' }
      end
    end
  end

  def remove
    @form = CustomFormsPlugin::Form.find(params[:id])
    begin
      @form.destroy
      session[:notice] = _('The %s was removed') % _(@form.kind)
    rescue
      session[:notice] = _('The %s could not be removed') % _(@form.kind)
    end
    redirect_to :action => 'index'
  end

  def submissions
    @form = CustomFormsPlugin::Form.find(params[:id])
    @sort_by = params[:sort_by] == 'author_name' ? 'author_name' : 'created_at'
    @submissions = @form.submissions.order(@sort_by).paginate(page: params[:npage], per_page: per_page)

    respond_to do |format|
      format.html
      format.csv do
        handler = CustomFormsPlugin::CsvHandler.new(@form)
        csv_content = handler.generate_csv
        send_data csv_content, type: 'text/csv', filename: "#{@form.name}.csv"
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

  def polls
    polls = queries_to_token_input('poll', params[:q])
    render plain: polls.to_json
  end

  def surveys
    surveys = queries_to_token_input('survey', params[:q])
    render plain: surveys.to_json
  end

  def import
    @form = CustomFormsPlugin::Form.find(params[:id])
    if request.post?
      if params[:csv_file].present? &&
         params[:csv_file].size > environment.submissions_csv_max_size
        session[:notice] = _('Maximum file size exceeded')
        redirect_to action: :import
        return
      end

      file_content = params[:csv_file].try(:read) || ''
      file_content = file_content.force_encoding('utf-8')
      handler = CustomFormsPlugin::CsvHandler.new(@form)

      @report = handler.import_csv(file_content)
      if @report[:errors].present?
        @failed_csv = CSV.generate do |csv|
          csv << @report[:header]
          @report[:errors].each do |error|
            csv << error[:row]
          end
        end
      end
      render 'report'
    end
  end

  def csv_template
    @form = CustomFormsPlugin::Form.find(params[:id])
    handler = CustomFormsPlugin::CsvHandler.new(@form)
    send_data handler.generate_template, type: 'text/csv',
              filename: "Template #{@form.name}.csv"
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

  def add_gallery_in_form(form, profile, data, remove_image)

    form_settings = Noosfero::Plugin::Settings.new(profile, CustomFormsPlugin)
    form_gallery = Gallery.where(id: form_settings.gallery_id).first
    return remove_form_image(form, form_gallery) if remove_image == "1"
    return form.save unless data

    unless form_gallery
      form_gallery = Gallery.create(profile: profile, name: _("Query Gallery"))
      form_settings.gallery_id = form_gallery.id
      form_settings.save!
    end

    form_image = UploadedFile.new(
      :uploaded_data => data,
      :profile => profile,
      :parent => nil,
    )

    form_gallery.images << form_image
    old_form_image = form.image
    form.image = form_image
    form_with_image = form.save && form_gallery.save
    UploadedFile.delete(old_form_image.id) if old_form_image
    form.errors.messages.merge!(form_gallery.errors.messages)
    form_with_image
  end

  def remove_empty_alternatives
    if params[:form]['fields_attributes'].present?
      params[:form]['fields_attributes'].each do |key, value|
        value['alternatives_attributes'].delete_if {|id, e| e['label'].blank? } if value['alternatives_attributes'].present?
      end
    end
  end

  def remove_form_image form, gallery
    return form.save if !(form.image && form.image.valid?)
    image_to_remove = form.image.id
    form.image = nil
    form.save
    gallery.images.find(image_to_remove).delete
    return UploadedFile.delete(image_to_remove)
  end

  def queries_to_token_input(kind, query)
    scope = profile.forms.where(kind: kind).order(:name)
    forms = find_by_contents(:forms, profile, scope, query)[:results]
    forms.map{ |f| { id: f.id, name: f.name } }
  end

  def per_page
    20
  end

end
