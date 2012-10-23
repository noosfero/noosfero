class CustomFormsPluginProfileController < ProfileController

  before_filter :has_access, :show

  def show
    @form = CustomFormsPlugin::Form.find(params[:id])
    if user
      @submission ||= CustomFormsPlugin::Submission.find_by_form_id_and_profile_id(@form.id,user.id)
      @submission ||= CustomFormsPlugin::Submission.new(:form_id => @form.id, :profile_id => user.id)
    else
      @submission ||= CustomFormsPlugin::Submission.new(:form_id => @form.id)
    end
    if request.post?
      begin
        extend(CustomFormsPlugin::Helper)
        answers = build_answers(params[:submission], @form)
        failed_answers = answers.select {|answer| !answer.valid? }
        if failed_answers.empty?
          if !user
            @submission.author_name = params[:author_name]
            @submission.author_email = params[:author_email]
          end
          @submission.save!
          answers.map {|answer| answer.submission = @submission; answer.save!}
        else
          @submission.valid?
          failed_answers.each do |answer|
            @submission.errors.add(answer.field.name.to_sym, answer.errors[answer.field.slug.to_sym])
          end
        end
        session[:notice] = _('Submission saved')
        redirect_to :action => 'show'
      rescue
        session[:notice] = _('Submission could not be saved')
      end
    end
  end

  private

  def has_access
    form = CustomFormsPlugin::Form.find(params[:id])
    render_access_denied if !form.accessible_to(user)
  end
end
