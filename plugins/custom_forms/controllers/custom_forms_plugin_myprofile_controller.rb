class CustomFormsPluginMyprofileController < MyProfileController

  protect 'post_content', :profile
  def index
    @forms = CustomFormsPlugin::Form.from(profile)
  end

  def create
    @form = CustomFormsPlugin::Form.new(:profile => profile)
    @fields = []
    @empty_field = CustomFormsPlugin::Field.new
    if request.post?
      begin
        @form.update_attributes!(params[:form])
        params[:fields] = format_kind(params[:fields])
        params[:fields] = format_choices(params[:fields])
        params[:fields] = set_form_id(params[:fields], @form.id)
        create_fields(new_fields(params))
        session['notice'] = _('Form created')
        redirect_to :action => 'index'
      rescue Exception => exception
        logger.error(exception.to_s)
        session['notice'] = _('Form could not be created')
      end
    end
  end

  def edit
    @form = CustomFormsPlugin::Form.find(params[:id])
    @fields = @form.fields
    @empty_field = CustomFormsPlugin::TextField.new
    if request.post?
      begin
        @form.update_attributes!(params[:form])
        params[:fields] = format_kind(params[:fields])
        params[:fields] = format_choices(params[:fields])
        remove_fields(params, @form)
        create_fields(new_fields(params))
        update_fields(edited_fields(params))
        session['notice'] = _('Form updated')
        redirect_to :action => 'index'
      rescue Exception => exception
        logger.error(exception.to_s)
        session['notice'] = _('Form could not be updated')
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

  private

  def new_fields(params)
    result = params[:fields].map {|id, hash| hash.has_key?(:real_id) ? nil : hash}.compact
    result.delete_if {|field| field[:name].blank?}
    result
  end

  def edited_fields(params)
    params[:fields].map {|id, hash| hash.has_key?(:real_id) ? hash : nil}.compact
  end

  def create_fields(fields)
    fields.each do |field|
      case field[:type]
      when 'text_field'
        CustomFormsPlugin::TextField.create!(field)
      when 'select_field'
        CustomFormsPlugin::SelectField.create!(field)
      else
        CustomFormsPlugin::Field.create!(field)
      end
    end
  end

  def update_fields(fields)
    fields.each do |field_attrs|
      field = CustomFormsPlugin::Field.find(field_attrs.delete(:real_id))
      field.attributes = field_attrs
      field.save! if field.changed?
    end
  end

  def format_kind(fields)
    fields.each do |id, field|
      next if field[:kind].blank?
      kind = field.delete(:kind)
      case kind
      when 'radio'
        field[:list] = false
        field[:multiple] = false
      when 'check_box'
        field[:list] = false
        field[:multiple] = true
      when 'select'
        field[:list] = true
        field[:multiple] = false
      when 'multiple_select'
        field[:list] = true
        field[:multiple] = true
      end
    end
    fields
  end

  def format_choices(fields)
    fields.each do |id, field|
      next if !field.has_key?(:choices)
      field[:choices] = field[:choices].map {|key, value| value}.inject({}) do |result, choice| 
        hash = (choice[:name].blank? || choice[:value].blank?) ? {} : {choice[:name] => choice[:value]}
        result.merge!(hash)
      end
    end
    fields
  end

  def remove_fields(params, form)
    present_fields = params[:fields].map{|id, value| value}.collect {|field| field[:real_id]}.compact
    form.fields.each {|field| field.destroy if !present_fields.include?(field.id.to_s) }
  end

  def set_form_id(fields, form_id)
    fields.each do |id, field|
      field[:form_id] = form_id
    end
    fields
  end
end
