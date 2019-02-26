class CustomFormsPluginProfileController < ProfileController
  helper CustomFormsPlugin::Helper  

  before_action :has_access, :only => [:show]
  before_action :can_view_results, :only => [:review]

  def show
    profile = Profile.find_by(identifier: params[:profile])
    @form = profile.forms.find_by(identifier: params[:id])
    if user
      @submission = CustomFormsPlugin::Submission.find_by form_id: @form.id, profile_id: user.id
      @submission ||= CustomFormsPlugin::Submission.new(:form => @form, :profile => user)
    else
      @submission = CustomFormsPlugin::Submission.new(:form => @form)
    end

    # build the answers
    @answers = if params[:submission] then @submission.build_answers params[:submission] else @submission.answers end

    if request.post?
      begin
        raise 'Submission already present!' if user.present? && CustomFormsPlugin::Submission.find_by(form_id: @form.id, profile_id: user.id)
        raise 'Form expired!' if @form.expired?

        if !user
          @submission.author_name = params[:author_name]
          @submission.author_email = params[:author_email]
        end

        if not @submission.save
          raise 'Submission failed: answers not valid'
        end

        redirect_to action: :confirmation, submission_id: @submission.id
      rescue
        session[:notice] = _('Submission could not be saved')
      end
    end
  end

  def confirmation
    @submission = CustomFormsPlugin::Submission.find_by(id: params[:submission_id])
    render_not_found unless @submission.present?
  end

  def review
    profile = Profile.find_by(identifier: params[:profile])
    @form = profile.forms.find_by(identifier: params[:id])
    @fields = @form.fields
    @sort_by = params[:sort_by] == 'author_name' ? 'author_name' : 'created_at'

    @graph = CustomFormsPlugin::Graph.new(@form)
    @query_results = @graph.query_results

    respond_to do |format|
      format.html
      format.csv do
        handler = CustomFormsPlugin::CsvHandler.new(@form)
        csv_content = handler.generate_csv
        send_data csv_content, type: 'text/csv', filename: "#{@form.name}.csv"
      end
    end
  end

  def download_field_answers
    profile = Profile.find_by(identifier: params[:profile])
    @form = profile.forms.find_by(identifier: params[:id])
    field = @form.fields.find_by(name: params[:field_name])

    respond_to do |format|
      format.html
      format.csv do
        handler = CustomFormsPlugin::CsvHandler.new(@form)
        csv_content = handler.generate_csv([field])
        send_data csv_content, type: 'text/csv', filename: "#{@form.name}_#{params[:field_name]}.csv"
      end
    end
  end

  def queries
    @order_options = [
      [_('Older'), 'older'],
      [_('Recent'), 'recent']]

    @kind_options =  [[_('All'), 'all']]
    @kind_options = CustomFormsPlugin::Form::KINDS.inject([[_('All'), 'all']]) do |memo, kind|
      memo << [_(kind.humanize.pluralize), kind]
    end

    @status_options = [
      [_('All'), 'all'],
      [_('Opened'), 'opened'],
      [_('Closed'), 'closed'],
      [_('To come'), 'to-come']]

    @q = params[:q]
    @order = available_orders.include?(params[:order]) ? params[:order] : 'recent'
    @kind = available_kinds.include?(params[:kind]) ? params[:kind] : 'all'
    @status = available_status.include?(params[:status]) ? params[:status] : 'all'

    @forms = profile.forms.accessible_to(user, profile)
    @forms = apply_order(@forms, @order)
    @forms = filter_kinds(@forms, @kind)
    @forms = filter_status(@forms, @status)
    @forms = find_by_contents(:forms, profile, @forms, @q, {:per_page => per_page, :page => params[:page]})[:results]
  end

  private

  def per_page
    5
  end

  def available_orders
    %w(older recent)
  end

  def available_kinds
    ['all'] + CustomFormsPlugin::Form::KINDS
  end

  def available_status
    %w(opened closed to-come)
  end

  def apply_order(forms, order)
    case order
    when 'older'
      forms.order('created_at ASC')
    when 'recent'
      forms.order('created_at DESC')
    else
      forms
    end
  end

  def filter_kinds(forms, kind)
    return forms if kind == 'all'
    forms.by_kind(kind)
  end

  def filter_status(forms, status)
    return forms if kind == 'all'
    forms.by_status(status)
  end

  def has_access
    form = CustomFormsPlugin::Form.find_by(identifier: params[:id])
    render_access_denied unless form.try(:display_to?, user)
  end

  def can_view_results
    form = CustomFormsPlugin::Form.find_by(identifier: params[:id])
    render_access_denied if form.present? && !form.show_results_for(user)
  end
end
