class WorkAssignmentPluginCmsController < CmsController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
 
  def upload_files
    @uploaded_files = []
    @article = @parent = check_parent(params[:parent_id])
    @email_notification = params[:article_email_notification]
    
    @target = @parent ? ('/%s/%s' % [profile.identifier, @parent.full_name]) : '/%s' % profile.identifier
    if @article
      record_coming
    end
    if request.post? && params[:uploaded_files]
      params[:uploaded_files].each do |file|
        if file != ''
          u = UploadedFile.new(:uploaded_data => file, :profile => profile, :parent => @parent)
          u.last_changed_by = user
          u.save!
          @uploaded_files << u
        end 
      end
      @errors = @uploaded_files.select { |f| f.errors.any? }
      if @errors.any?
        render :action => 'upload_files', :id => @parent_id
      else
        if @back_to
          if @email_notification == 'true'
            redirect_to :controller => 'work_assignment_plugin_cms', :action => 'send_email', :id => @parent.id, :files_id => @uploaded_files, :confirm => true
          else
            redirect_to @back_to
          end
        elsif @parent
          redirect_to :controller => 'cms', :action => 'view', :id => @parent.id
        else
          redirect_to :controller => 'cms', :action => 'index'
        end
      end
    end
  end

  def send_email
    @parent = check_parent(params[:id])
    @files_id_list = params[:files_id]
    @target = ['',@parent.url[:profile], @parent.url[:page]].join('/')
    @contact
    if request.post? && params[:confirm] == 'true'
      @files_paths = []
      @files_id_list = params[:self_files_id]
      
      @files_id_list.each do |file_id|
        @file = environment.articles.find_by_id(file_id)
        @real_file_url = "http://#{@file.url[:host]}:#{@file.url[:port]}/ #{@file.url[:profile]}/#{@file.path}"
        @files_paths << @real_file_url
        unless params[:contact][:message].include? "#{@real_file_url}"
          params[:contact][:message] += "<br> Clique <a href='#{@real_file_url}'>aqui</a> para acessar o arquivo ou acesse pela URL: <br>"
          params[:contact][:message] += "<br><a href='#{@real_file_url}'>#{@real_file_url}</a>"
        end
      end
      @message = "AVISO: O aluno deve imprimir este email e entrega-lo na secretaria como comprovante do envio!"
      unless params[:contact][:message].include? "#{@message}"
        params[:contact][:message] += "<br><br>#{@message}"
      end

      @contact = user.build_contact(profile, params[:contact])
      if @contact.deliver
        session[:notice] = _('Contact successfully sent')
        redirect_to @target
      else
        session[:notice] = _('Contact not sent')
      end
    elsif request.post? && params[:confirm] == 'false'
      if @target
        session[:notice] = _('Email not sent')
        redirect_to @target
      elsif @parent
        redirect_to :action => 'view', :id => @parent.id, :paths_list => @paths_list
      else
        redirect_to :action => 'index'
      end
    else
      @contact = user.build_contact(profile)
    end
  end

  def destroy
    @article = profile.articles.find(params[:id])
    if request.post?
      @article.destroy
      session[:notice] = _("\"#{@article.name}\" was removed.")
      referer = Rails.application.routes.recognize_path URI.parse(request.referer).path rescue nil
      redirect_to referer
    end
  end
end