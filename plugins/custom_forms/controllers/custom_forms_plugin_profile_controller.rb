class CustomFormsPluginProfileController < ProfileController
  before_filter :has_access, :show

  def show
    extend(CustomFormsPlugin::Helper)

    @form = CustomFormsPlugin::Form.find(params[:id])
    if user
      @submission = CustomFormsPlugin::Submission.find_by_form_id_and_profile_id(@form.id,user.id)
      @submission ||= CustomFormsPlugin::Submission.new(:form => @form, :profile => user)
    else
      @submission = CustomFormsPlugin::Submission.new(:form => @form)
    end

    # build the answers
    @answers = if params[:submission] then @submission.build_answers params[:submission] else @submission.answers end

    if request.post?
      begin
        raise 'Submission already present!' if user.present? && CustomFormsPlugin::Submission.find_by_form_id_and_profile_id(@form.id,user.id)
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

  private

  def has_access
    form = CustomFormsPlugin::Form.find(params[:id])
    render_access_denied if !form.accessible_to(user)
  end
end
