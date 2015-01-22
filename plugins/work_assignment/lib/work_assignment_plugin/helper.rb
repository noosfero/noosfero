module WorkAssignmentPlugin::Helper
  include CmsHelper
  
  def display_submissions(work_assignment, user)
    return if work_assignment.submissions.empty?
    content_tag('table',
      content_tag('tr',
        content_tag('th', c_('Author'), :style => 'width: 50%') +
        content_tag('th', _('Submission date')) +
        content_tag('th', _('Versions'), :style => 'text-align: center') +
        content_tag('th', '') +
        content_tag('th', '')
      ).html_safe +
      work_assignment.children.map {|author_folder| display_author_folder(author_folder, user)}.join("\n").html_safe
    )
  end

  def display_author_folder(author_folder, user)
    return if author_folder.children.empty?
    content_tag('tr',
      content_tag('td', link_to_last_submission(author_folder, user)) +
      content_tag('td', time_format(author_folder.children.last.created_at)) +
      content_tag('td', author_folder.children.count, :style => 'text-align: center') +
      content_tag('td', content_tag('button', _('View all versions'), :class => 'view-author-versions', 'data-folder-id' => author_folder.id)) +
      content_tag('td', display_privacy_button(author_folder, user))
    ).html_safe +
    author_folder.children.map {|submission| display_submission(submission, user)}.join("\n").html_safe
  end

  def display_submission(submission, user)
    content_tag('tr',
      content_tag('td', link_to_submission(submission, user)) +
      content_tag('td', time_format(submission.created_at))+
      content_tag('td', '') +
      content_tag('td', 
        if submission.parent.parent.allow_post_content?(user)
          display_delete_button(submission)
        end
      ),
      :class => "submission-from-#{submission.parent.id}",
      :style => 'display: none'
    )
  end

  def link_to_submission(submission, user)
    if WorkAssignmentPlugin.can_download_submission?(user, submission)
      link_to(submission.name, submission.url)
    else
      submission.name
    end
  end

  def link_to_last_submission(author_folder, user)
    if WorkAssignmentPlugin.can_download_submission?(user, author_folder.children.last)
      link_to(author_folder.name, author_folder.children.last.url)
    else
      author_folder.name
    end
  end

  # FIXME Copied from custom-froms. Consider passing it to core...
  def time_format(time)
    minutes = (time.min == 0) ? '' : ':%M'
    hour = (time.hour == 0 && minutes.blank?) ? '' : ' %H'
    h = hour.blank? ? '' : 'h'
    time.strftime("%Y-%m-%d#{hour+minutes+h}")
  end

  def display_delete_button(article)
    expirable_button article, :delete, _('Delete'), 
    {:controller =>'cms', :action => 'destroy', :id => article.id },
    :method => :post, :confirm => delete_article_message(article)
  end

  def display_privacy_button(author_folder, user)
    folder = environment.articles.find_by_id(author_folder.id)
    work_assignment = folder.parent
    @back_to = url_for(work_assignment.url)

    if(user && work_assignment.allow_visibility_edition &&
      ((author_folder.author_id == user.id && (user.is_member_of? profile)) ||
      user.has_permission?('view_private_content', profile)))

      @tokenized_children = prepare_to_token_input(
                            profile.members.includes(:articles_with_access).find_all{ |m|
                              m.articles_with_access.include?(folder)
                            })
      button :edit, _('Edit'), { :controller => 'work_assignment_plugin_myprofile',
      :action => 'edit_visibility', :article_id => folder.id,
      :tokenized_children => @tokenized_children, :back_to => @back_to}, :method => :post
    end
  end
end
