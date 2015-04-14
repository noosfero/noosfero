module SendEmailPluginBaseController
  def deliver
    if request.post?
      @context_url = profile ? profile.url : {:host => environment.default_hostname, :controller => 'home'}
      @mail = SendEmailPlugin::Mail.new(
        :from => environment.noreply_email,
        :to => params[:to],
        :message => params[:message],
        :environment => environment,
        :params => params.dup
      )
      @mail.subject = params[:subject] unless params[:subject].blank?
      if @mail.valid?
        @referer = request.referer
        SendEmailPlugin::Sender.send_message(@referer, @context_url, @mail).deliver
        if request.xhr?
          render :text => _('Message sent')
        else
          render :action => 'success'
        end
      else
        if request.xhr?
          render_dialog_error_messages :mail
        else
          render :action => 'fail'
        end
      end
    else
      render_access_denied
    end
  end
end
