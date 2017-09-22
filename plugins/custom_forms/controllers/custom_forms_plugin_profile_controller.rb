class CustomFormsPluginProfileController < ProfileController
  before_filter :has_access, :show

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

  private

  def has_access
    form = CustomFormsPlugin::Form.find_by(identifier: params[:id])
    render_access_denied if !form.accessible_to(user)
  end
end
