module TaskHelper

  def task_email_template(description, email_templates, task, include_blank=true)
    return '' unless email_templates.present?

    content_tag(
      :div,
      labelled_form_field(description, select_tag("tasks[#{task.id}][task][email_template_id]", options_from_collection_for_select(email_templates, :id, :name), :include_blank => include_blank, 'data-url' => url_for(:controller => 'profile_email_templates', :action => 'show_parsed', :profile => profile.identifier))),
      :class => 'template-selection'
    )
  end

end
