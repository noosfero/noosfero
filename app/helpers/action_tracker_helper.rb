module ActionTrackerHelper

  def create_article_description ta
    _('published an article %{title} %{time_ago}') % { title: link_to(truncate(ta.get_name), ta.get_url), time_ago: time_ago(ta) }
  end

  def new_friendship_description ta
    n_("has made 1 new friend %{time_ago}<hr/>%{name}", "has made %{num} new friends %{time_ago}<hr/>%{name}", ta.get_friend_name.size).html_safe % {
      num: ta.get_friend_name.size,
      name: safe_join(ta.collect_group_with_index(:friend_name) do |n,i|
        link_to image_tag(ta.get_friend_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/person-icon.png")),
                ta.get_friend_url[i], title: n
      end),
      time_ago: time_ago(ta)
    }
  end

  def new_follower_description ta
    n_('has 1 new follower %{time_ago}<hr/>%{name}', 'has %{num} new followers %{time_ago}<hr/>%{name}', ta.get_follower_name.size).html_safe % {
      num: ta.get_follower_name.size,
      name: safe_join(ta.collect_group_with_index(:follower_name) do |n,i|
        link_to image_tag(ta.get_follower_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/person-icon.png")),
          ta.get_follower_url[i], title: n
      end),
      time_ago: time_ago(ta)
    }
  end

  def join_community_description ta
    n_('has joined 1 community %{time_ago}<hr/>%{name}', 'has joined %{num} communities %{time_ago}<hr />%{name}', ta.get_resource_name.size).html_safe % {
      num: ta.get_resource_name.size,
      name: safe_join(ta.collect_group_with_index(:resource_name) do |n,i|
       link = link_to image_tag(ta.get_resource_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/community-icon.png")),
                ta.get_resource_url[i], title: n
      end),
      time_ago: time_ago(ta)
    }
  end

  def add_member_in_community_description ta
    _('has joined the community %{time_ago}' % { time_ago: time_ago(ta) } )
  end

  def upload_image_description ta
    total = ta.get_view_url.size
    (n_('uploaded %{total} image %{time_ago}', 'uploaded %{total} images %{time_ago}', total) % { total: total, time_ago: time_ago(ta) }) +
      tag(:hr) +
      ta.collect_group_with_index(:thumbnail_path) do |t,i|
        if total == 1
          link_to image_tag(t), ta.get_view_url[i], class: 'upimg'
        else
          pos = total-i;
          morethen2 = pos>2 ? 'morethen2' : ''
          morethen5 = pos>5 ? 'morethen5' : ''
          t = t.gsub(/(.*)(display)(.*)/, '\\1thumb\\3')

          link_to '&nbsp;'.html_safe, ta.get_view_url[i],
            style: "background-image:url(#{t})",
            class: "upimg pos#{pos} #{morethen2} #{morethen5}"
        end
      end.reverse.join +
      if total <= 5 then ''.html_safe else content_tag :span, '&hellip;'.html_safe,
        class: 'more', onclick: "this.parentNode.className+=' show-all'" end +
      tag(:br, style: 'clear: both')
  end

  def leave_scrap_description ta
    _('sent a message to %{receiver} %{time_ago}<hr/>%{message}') % {
      receiver: link_to(ta.get_receiver_name, ta.get_receiver_url),
      message: auto_link_urls(ta.get_content),
      time_ago: time_ago(ta)
    }
  end

  def reply_scrap_on_self_description ta
    _('replied to a scrap from %{receiver} %{time_ago}<hr /> "%{message}"') % {
      receiver: link_to(ta.get_receiver_name, ta.get_receiver_url),
      message: auto_link_urls(ta.get_content),
      time_ago: time_ago(ta)
    }
  end

  def leave_scrap_to_self_description ta
    _('%{time_ago}<hr /> "%{text}"') % {
      text: auto_link_urls(ta.get_content),
      time_ago: time_ago(ta)
    }
  end

  def favorite_enterprise_description ta
    (_('favorited enterprise %{title} %{time_ago}') % {
      title: link_to(truncate(ta.get_enterprise_name), ta.get_enterprise_url),
      time_ago: time_ago(ta)
    }).html_safe
  end

  def time_ago ta
    content_tag(:span,
                "#{content_tag(:span, "•", class: 'bullet-separator')}#{time_ago_in_words(ta.created_at)} #{_('ago')}".html_safe,
                class: 'profile-activity-time')
  end

end
