require 'noosfero/i18n'

# ActionTracker plugin stuff

ActionTrackerConfig.verbs = {
  :create_article => { 
    :description => _('published %s %s: %s') % ['{{ta.get_name.size}}', '{{_(pluralize_without_count(ta.get_name.size, "article"))}}', '{{ta.collect_group_with_index(:name){ |n,i| link_to(truncate(n), ta.get_url[i])}.to_sentence(:connector => _("and"))}}'],
    :type => :groupable
  },
  :update_article => { 
    :description => _('updated %s %s: %s') % ['{{ta.get_name.uniq.size}}', '{{_(pluralize_without_count(ta.get_name.uniq.size, "article"))}}', '{{ta.collect_group_with_index(:name){ |n,i| link_to(truncate(n), ta.get_url[i])}.uniq.to_sentence(:connector => _("and"))}}'],
    :type => :groupable
  },
  :remove_article => { 
    :description => _('removed %s %s: %s') % ['{{ta.get_name.size}}', '{{_(pluralize_without_count(ta.get_name.size, "article"))}}', '{{ta.get_name.collect{ |n| truncate(n) }.to_sentence(:connector => _("and"))}}'],
    :type => :groupable
  },
  :publish_article_in_community => {
    :description => _('published %s %s in communities: %s') % ['{{ta.get_name.size}}', '{{_(pluralize_without_count(ta.get_name.size, "article"))}}', '{{ta.collect_group_with_index(:name){ |n, i| link_to(truncate(n), ta.get_url[i]) + " (" + _("in") + " " + link_to(ta.get_profile_name[i], ta.get_profile_url[i]) + ")"}.to_sentence(:connector => _("and"))}}'],
    :type => :groupable
  },
  :new_friendship => { 
    :description => _('has made %s %s:<br />%s') % ['{{ta.get_friend_name.size}}', '{{_(pluralize_without_count(ta.get_friend_name.size, "new friend"))}}', '{{ta.collect_group_with_index(:friend_name){ |n,i| link_to(content_tag(:img, nil, :src => (ta.get_friend_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/person-icon.png"))), ta.get_friend_url[i], :title => n)}.join}}'],
    :type => :groupable
  },
  :join_community => { 
    :description => _('has joined %s %s:<br />%s') % ['{{ta.get_resource_name.size}}', '{{_(pluralize_without_count(ta.get_resource_name.size, "community"))}}', '{{ta.collect_group_with_index(:resource_name){ |n,i| link_to(content_tag(:img, nil, :src => (ta.get_resource_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/community-icon.png"))), ta.get_resource_url[i], :title => n)}.join}}'],
    :type => :groupable
  },
  :leave_community => { 
    :description => _('has left %s %s:<br />%s') % ['{{ta.get_resource_name.size}}', '{{_(pluralize_without_count(ta.get_resource_name.size, "community"))}}', '{{ta.collect_group_with_index(:resource_name){ |n,i| link_to(content_tag(:img, nil, :src => (ta.get_resource_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/community-icon.png"))), ta.get_resource_url[i], :title => n)}.join}}'],
    :type => :groupable
  },
  :upload_image => { 
    :description => _('uploaded %s %s:<br />%s<br />%s') % ['{{ta.get_view_url.size}}', '{{_(pluralize_without_count(ta.get_view_url.size, "image"))}}', '{{ta.collect_group_with_index(:thumbnail_path){ |t,i| content_tag(:span, link_to(content_tag(:img, nil, :src => t), ta.get_view_url[i]))}.last(3).join}}', '{{unique_with_count(ta.collect_group_with_index(:parent_name){ |n,i| link_to(n, ta.get_parent_url[i])}, _("in the gallery")).join("<br />")}}'],
    :type => :groupable
  },
  :leave_comment => {
    :description => _('has left a comment entitled "%s" on the article %s: <br /> "%s" (%s)') % ["{{truncate(ta.get_title)}}", "{{link_to(truncate(ta.get_article_title), ta.get_article_url)}}", "{{truncate(ta.get_body, 50)}}", "{{link_to(_('read'), ta.get_url)}}"]
  },
  :leave_scrap => {
    :description => _('sent a message to %s: <br /> "%s"') % ["{{link_to(ta.get_receiver_name, ta.get_receiver_url)}}", "{{auto_link_urls(ta.get_content)}}"]
  },
  :leave_scrap_to_self => {
    :description => _('wrote: <br /> "%s"') % "{{auto_link_urls(ta.get_content)}}"
  }
}

ActionTrackerConfig.current_user_method = :current_person

ActionTrackerConfig.timeout = 24.hours
