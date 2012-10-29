module WorkAssignmentPlugin::Helper
  def display_submissions(work_assignment, user)
    return if work_assignment.submissions.empty?
    content_tag('table',
      content_tag('tr',
        content_tag('th', _('Author'), :style => 'width: 50%') +
        content_tag('th', _('Submission date')) +
        content_tag('th', _('Versions'), :style => 'text-align: center') +
        content_tag('th', '')
      ) +
      work_assignment.children.map {|author_folder| display_author_folder(author_folder, user)}.join("\n")
    )
  end

  def display_author_folder(author_folder, user)
    return if author_folder.children.empty?
    content_tag('tr',
      content_tag('td', link_to_last_submission(author_folder, user)) +
      content_tag('td', time_format(author_folder.children.last.created_at)) +
      content_tag('td', author_folder.children.count, :style => 'text-align: center') +
      content_tag('td', content_tag('button', _('View all versions'), :class => 'view-author-versions', 'data-folder-id' => author_folder.id))
    ) +
    author_folder.children.map {|submission| display_submission(submission, user)}.join("\n")
  end

  def display_submission(submission, user)
    content_tag('tr',
      content_tag('td', link_to_submission(submission, user)) +
      content_tag('td', time_format(submission.created_at), :colspan => 3),
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

end
