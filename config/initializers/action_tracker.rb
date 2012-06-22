require 'noosfero/i18n'

# ActionTracker plugin stuff

ActionTrackerConfig.verbs = {

  :create_article => { 
    :description => lambda { _('published an article: %{title}') % { :title => '{{link_to(truncate(ta.get_name), ta.get_url)}}' } }
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

  :upload_image => { 
    :description => lambda { n_('uploaded 1 image<br />%{thumbnails}<br style="clear: both;" />', 'uploaded %{num} images<br />%{thumbnails}<br style="clear: both;" />', get_view_url.size) % { :num => get_view_url.size, :thumbnails => '{{ta.collect_group_with_index(:thumbnail_path){ |t,i| content_tag(:span, link_to(image_tag(t), ta.get_view_url[i]))}.last(3).join}}' } },
    :type => :groupable
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
