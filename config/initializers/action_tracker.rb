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
    :description => lambda do
      total = get_view_url.size
      n_('uploaded 1 image', 'uploaded %d images', total) % total +
      '<br />{{'+
      'ta.collect_group_with_index(:thumbnail_path) { |t,i|' +
      "  if ( #{total} == 1 );" +
      '    link_to( image_tag(t), ta.get_view_url[i], :class => \'upimg\' );' +
      '   else;' +
      "    pos = #{total}-i;" +
      '    morethen2 = pos>2 ? \'morethen2\' : \'\';' +
      '    morethen5 = pos>5 ? \'morethen5\' : \'\';' +
      '    t = t.gsub(/(.*)(display)(.*)/, \'\\1thumb\\3\');' +
      '    link_to( \'&nbsp;\', ta.get_view_url[i],' +
      '      :style => "background-image:url(#{t})",' +
      '      :class => "upimg pos#{pos} #{morethen2} #{morethen5}" );' +
      '  end' +
      '}.reverse.join}}' +
      ( total > 5 ?
        '<span class="more" onclick="this.parentNode.className+=\' show-all\'">' +
        '&hellip;</span>' : '' ) +
      '<br style="clear: both;" />'
    end,
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
