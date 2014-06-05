class CommentController < ApplicationController

  needs_profile

  before_filter :can_update?, :only => [:edit, :update]

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
    @plugins.dispatch(:filter_comment, @comment)

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

    if @comment.need_moderation?
      @comment.created_at = Time.now
      ApproveComment.create!(:requestor => @comment.author, :target => profile, :comment_attributes => @comment.attributes.to_json)

      respond_to do |format|
        format.js do
          render :json => { :render_target => nil, :msg => _('Your comment is waiting for approval.') }
        end
      end
      return
    end

    if @comment.save
      @plugins.dispatch(:process_extra_comment_params, [@comment,params])
    end

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

    if comment && comment.can_be_destroyed_by?(user) && comment.destroy
      render :text => {'ok' => true}.to_json, :content_type => 'application/json'
    else
      session[:notice] = _("The comment was not removed.")
      render :text => {'ok' => false}.to_json, :content_type => 'application/json'
    end
  end

  def mark_as_spam
    comment = profile.comments_received.find(params[:id])
    if comment.can_be_marked_as_spam_by?(user)
      comment.spam!
      render :text => {'ok' => true}.to_json, :content_type => 'application/json'
    else
      session[:notice] = _("You couldn't mark this comment as spam.")
      render :text => {'ok' => false}.to_json, :content_type => 'application/json'
    end
  end

  def edit
    render :partial => "comment_form", :locals => {:comment => @comment, :display_link => params[:reply_of_id].present?, :edition_mode => true, :show_form => true}
  end

  def update
    if @comment.update_attributes(params[:comment])
      @plugins.dispatch(:process_extra_comment_params, [@comment,params])

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

  def check_actions
    comment = profile.comments_received.find(params[:id])
    ids = @plugins.dispatch(:check_comment_actions, comment).collect do |action|
      action.kind_of?(Proc) ? self.instance_eval(&action) : action
    end.flatten.compact
    render :json => {:ids => ids}
  end

  protected

  def pass_without_comment_captcha?
    logged_in? && !environment.enabled?('captcha_for_logged_users')
  end
  helper_method :pass_without_comment_captcha?

  def can_update?
    begin
      @comment = profile.comments_received.find(params[:id])
      raise ActiveRecord::RecordNotFound unless @comment.can_be_updated_by?(user) # Not reveal that the comment exists
    rescue ActiveRecord::RecordNotFound
      render_not_found
      return
    end
  end

end
