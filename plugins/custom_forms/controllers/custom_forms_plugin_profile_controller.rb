class CustomFormsPluginProfileController < ProfileController
  before_filter :has_access, :show

  def show
    extend(CustomFormsPlugin::Helper)

    @form = CustomFormsPlugin::Form.find(params[:id])
    if user
      @submission ||= CustomFormsPlugin::Submission.find_by_form_id_and_profile_id(@form.id,user.id)
      @submission ||= CustomFormsPlugin::Submission.new(:form => @form, :profile => user)
    else
      @submission ||= CustomFormsPlugin::Submission.new(:form => @form)
    end

    # build the answers
    @submission.answers.push(*(answers = build_answers(params[:submission], @form))) if params[:submission]

    if request.post?
      begin
        raise 'Submission already present!' if user.present? && CustomFormsPlugin::Submission.find_by_form_id_and_profile_id(@form.id,user.id)
        raise 'Form expired!' if @form.expired?

        # @submission.answers for some reason has the same answer twice
        failed_answers = answers.select {|answer| !answer.valid? }

        if failed_answers.empty?
          # Save the submission
          ActiveRecord::Base.transaction do
            if !user
              @submission.author_name = params[:author_name]
              @submission.author_email = params[:author_email]
            end
            @submission.save!
          end
        else
          @submission.errors.clear
          failed_answers.each do |answer|
            answer.valid?
            answer.errors.each do |attribute, msg|
              @submission.errors.add(answer.field.id.to_s.to_sym, msg)
            end
          end
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
