class CustomFormsPluginProfileController < ProfileController
  before_filter :has_access, :only => [:show]

  def show
    extend(CustomFormsPlugin::Helper)

    @form = CustomFormsPlugin::Form.find_by(identifier: params[:id])
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
        session[:notice] = _('Submission saved')
        redirect_to :action => 'show'
      rescue
        session[:notice] = _('Submission could not be saved')
      end
    end
  end

  def review
    @form = CustomFormsPlugin::Form.find_by(identifier: params[:id])
    @fields = @form.fields
    @sort_by = params[:sort_by] == 'author_name' ? 'author_name' : 'created_at'

    @graph = CustomFormsPlugin::Graph.new(@form)
    @query_results = @graph.query_results

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

    @forms = profile.forms
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
    render_access_denied if form.blank? || !form.accessible_to(user)
  end
end
