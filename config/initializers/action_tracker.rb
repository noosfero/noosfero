require 'noosfero/i18n'

# ActionTracker plugin stuff

ActionTrackerConfig.verbs = {

  :create_article => { 
    :description => lambda { n_('published 1 article: %{title}', 'published %{num} articles: %{title}', get_name.size) % { :num => get_name.size, :title => '{{ta.collect_group_with_index(:name){ |n,i| link_to(truncate(n), ta.get_url[i]) }.to_sentence(:connector => "%s")}}' % _("and") } },
    :type => :groupable
  },

  :update_article => { 
    :description => lambda { n_('updated 1 article: %{title}', 'updated %{num} articles: %{title}', get_name.uniq.size) % { :num => get_name.uniq.size, :title => '{{ta.collect_group_with_index(:name){ |n,i| link_to(truncate(n), ta.get_url[i]) }.uniq.to_sentence(:connector => "%s")}}' % _("and") } },
    :type => :groupable
  },

  :remove_article => { 
    :description => lambda { n_('removed 1 article: %{title}', 'removed %{num} articles: %{title}', get_name.size) % { :num => get_name.size, :title => '{{ta.get_name.collect{ |n| truncate(n) }.to_sentence(:connector => "%s")}}' % _("and") } },
    :type => :groupable
  },

  :new_friendship => { 
    :description => lambda { n_('has made 1 new friend:<br />%{name}', 'has made %{num} new friends:<br />%{name}', get_friend_name.size) % { :num => get_friend_name.size, :name => '{{ta.collect_group_with_index(:friend_name){ |n,i| link_to(image_tag(ta.get_friend_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/person-icon.png")), ta.get_friend_url[i], :title => n)}.join}}' } },
    :type => :groupable
  },

  :join_community => { 
    :description => lambda { n_('has joined 1 community:<br />%{name}', 'has joined %{num} communities:<br />%{name}', get_resource_name.size) % { :num => get_resource_name.size, :name => '{{ta.collect_group_with_index(:resource_name){ |n,i| link_to(image_tag(ta.get_resource_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/community-icon.png")), ta.get_resource_url[i], :title => n)}.join}}' } },
    :type => :groupable
  },

  :add_member_in_community => { 
    :description => lambda { _('has joined the community.') },
  },

  :remove_member_in_community => { 
    :description => lambda { _('has left the community.') },
  },

  :leave_community => {
    :description => lambda { n_('has left 1 community:<br />%{name}', 'has left %{num} communities:<br />%{name}', get_resource_name.size) % { :num => get_resource_name.size, :name => '{{ta.collect_group_with_index(:resource_name){ |n,i| link_to(image_tag(ta.get_resource_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/community-icon.png")), ta.get_resource_url[i], :title => n)}.join}}' } },
    :type => :groupable
  },

  :upload_image => { 
    :description => lambda { n_('uploaded 1 image:<br />%{thumbnails}<br />%{details}', 'uploaded %{num} images:<br />%{thumbnails}<br />%{details}', get_view_url.size) % { :num => get_view_url.size, :thumbnails => '{{ta.collect_group_with_index(:thumbnail_path){ |t,i| content_tag(:span, link_to(image_tag(t), ta.get_view_url[i]))}.last(3).join}}', :details => '{{unique_with_count(ta.collect_group_with_index(:parent_name){ |n,i| link_to(n, ta.get_parent_url[i])}, "%s").join("<br />")}}' % _("in the gallery") } },
    :type => :groupable
  },

  :leave_comment => {
    :description => lambda { _('has left a comment entitled "%{title}" on the article %{article}: <br /> "%{comment}" (%{read})') % { :title => "{{truncate(ta.get_title)}}", :article => "{{link_to(truncate(ta.get_article_title), ta.get_article_url)}}", :comment => "{{truncate(ta.get_body, 50)}}", :read => '{{link_to("%s", ta.get_url)}}' % _("read") } }
  },

  :leave_scrap => {
    :description => lambda { _('sent a message to %{receiver}: <br /> "%{message}"') % { :receiver => "{{link_to(ta.get_receiver_name, ta.get_receiver_url)}}", :message => "{{auto_link_urls(ta.get_content)}}" } }
  },

  :leave_scrap_to_self => {
    :description => lambda { _('wrote: <br /> "%{text}"') % { :text => "{{auto_link_urls(ta.get_content)}}" } }
  }
}

ActionTrackerConfig.current_user_method = :current_person

ActionTrackerConfig.timeout = 24.hours
