class CommentController < ApplicationController

  needs_profile

  def create
    begin
      @page = profile.articles.find(params[:id])
    rescue
      @page = nil
    end

    # page not found, give error
    if @page.nil?
      respond_to do |format|
        format.js do
           render :json => { :msg => _('Page not found.')}
         end
       end
      return
    end

    unless @page.accept_comments?
      respond_to do |format|
        format.js do
           render :json => { :msg => _('Comment not allowed in this article')}
         end
       end
      return
    end

    @comment = Comment.new(params[:comment])
    @comment.author = user if logged_in?
    @comment.article = @page
    @comment.ip_address = request.remote_ip
    @comment.user_agent = request.user_agent
    @comment.referrer = request.referrer
    plugins_filter_comment(@comment)

    if @comment.rejected?
      respond_to do |format|
        format.js do
           render :json => { :msg => _('Comment was rejected')}
         end
       end
      return
    end

    if !@comment.valid? || (not pass_without_comment_captcha? and not verify_recaptcha(:model => @comment, :message => _('Please type the words correctly')))
      respond_to do |format|
        format.js do
          render :json => { 
             :render_target => 'form',
             :html => render_to_string(:partial => 'comment_form', :object => @comment, :locals => {:comment => @comment, :display_link => true, :show_form => true})
          }
        end
      end
      return
    end

    if @comment.article.moderate_comments? && !(@comment.author && @comment.author_id == @comment.article.author_id)
      @comment.created_at = Time.now
      ApproveComment.create!(:requestor => @comment.author, :target => profile, :comment_attributes => @comment.attributes.to_json)

      respond_to do |format|
        format.js do
          render :json => { :render_target => nil, :msg => _('Your comment is waiting for approval.') }
        end
      end
      return
    end

    @comment.save

    respond_to do |format|
      format.js do
        comment_to_render = @comment.comment_root
        render :json => { 
            :render_target => comment_to_render.anchor,
            :html => render_to_string(:partial => 'comment', :locals => {:comment => comment_to_render, :display_link => true}),
            :msg => _('Comment successfully created.')
         }
      end
    end
  end

  def destroy
    comment = profile.comments_received.find(params[:id])

    could_remove = (user == comment.author || user == comment.profile || user.has_permission?(:moderate_comments, comment.profile))
    if comment && could_remove && comment.destroy
      render :text => {'ok' => true}.to_json, :content_type => 'application/json'
    else
      session[:notice] = _("The comment was not removed.")
      render :text => {'ok' => false}.to_json, :content_type => 'application/json'
    end
  end

  def mark_as_spam
    comment = profile.comments_received.find(params[:id])
    could_mark_as_spam = (user == comment.profile || user.has_permission?(:moderate_comments, comment.profile))

    if logged_in? && could_mark_as_spam
      comment.spam!
      render :text => {'ok' => true}.to_json, :content_type => 'application/json'
    else
      session[:notice] = _("You couldn't mark this comment as spam.")
      render :text => {'ok' => false}.to_json, :content_type => 'application/json'
    end
  end

  def edit
    begin
      @comment = profile.comments_received.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @comment = nil
    end

    if @comment.nil?
      render_not_found
      return
    end

    display_link = params[:reply_of_id].present? && !params[:reply_of_id].empty?

    render :partial => "comment_form", :locals => {:comment => @comment, :display_link => display_link, :edition_mode => true, :show_form => true}
  end

  def update
    begin
      @comment = profile.comments_received.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @comment = nil
    end

    if @comment.nil? or user != @comment.author
      render_not_found
      return
    end

    if @comment.update_attributes(params[:comment])
      respond_to do |format|
        format.js do
          comment_to_render = @comment.comment_root
          render :json => {
            :ok => true,
            :render_target => comment_to_render.anchor,
            :html => render_to_string(:partial => 'comment', :locals => {:comment => comment_to_render})
          }
        end
      end
    else
     respond_to do |format|
       format.js do
         render :json => {
           :ok => false,
           :render_target => 'form',
           :html => render_to_string(:partial => 'comment_form', :object => @comment, :locals => {:comment => @comment, :display_link => false, :edition_mode => true, :show_form => true})
         }
       end
     end
   end
  end
  
  #FIXME make this test
  def check_actions
    comment = profile.comments_received.find(params[:id])
    ids = @plugins.dispatch(:check_comment_actions, comment).collect do |action|
      action.kind_of?(Proc) ? self.instance_eval(&action) : action
    end.flatten.compact
    render :json => {:ids => ids}
  end

  protected

  def plugins_filter_comment(comment)
    @plugins.each do |plugin|
      plugin.filter_comment(comment)
    end
  end

  def pass_without_comment_captcha?
    logged_in? && !environment.enabled?('captcha_for_logged_users')
  end
  helper_method :pass_without_comment_captcha?

end
