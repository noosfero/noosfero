module ActionTrackerHelper

  def create_article_description ta
    _('published an article: %{title}') % { title: link_to(truncate(ta.get_name), ta.get_url) }
  end

  def new_friendship_description ta
    n_('has made 1 new friend:<br />%{name}', 'has made %{num} new friends:<br />%{name}', ta.get_friend_name.size) % {
      num: ta.get_friend_name.size,
      name: ta.collect_group_with_index(:friend_name) do |n,i|
        link_to image_tag(ta.get_friend_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/person-icon.png")),
                ta.get_friend_url[i], title: n
      end.join
    }
  end

  def join_community_description ta
    n_('has joined 1 community:<br />%{name}', 'has joined %{num} communities:<br />%{name}', ta.get_resource_name.size) % {
      num: ta.get_resource_name.size,
      name: ta.collect_group_with_index(:resource_name) do |n,i|
        link_to image_tag(ta.get_resource_profile_custom_icon[i] || default_or_themed_icon("/images/icons-app/community-icon.png")),
                ta.get_resource_url[i], title: n
      end.join
    }
  end

  def add_member_in_community_description ta
    _('has joined the community.')
  end

  def upload_image_description ta
    total = ta.get_view_url.size
    (n_('uploaded 1 image', 'uploaded %d images', total) % total) +
      tag(:br) +
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

  def reply_scrap_description ta
    _('sent a message to %{receiver}: <br /> "%{message}"') % {
      receiver: link_to(ta.get_receiver_name, ta.get_receiver_url),
      message: auto_link_urls(ta.get_content)
    }
  end

  alias :leave_scrap_description :reply_scrap_description
  alias :reply_scrap_on_self_description :reply_scrap_description

  def leave_scrap_to_self_description ta
    _('wrote: <br /> "%{text}"') % {
      text: auto_link_urls(ta.get_content)
    }
  end

  def create_product_description ta
    _('created the product %{title}') % {
      title: link_to(truncate(ta.get_name), ta.get_url),
    }
  end

  def update_product_description ta
    _('updated the product %{title}') % {
      title: link_to(truncate(ta.get_name), ta.get_url),
    }
  end

  def remove_product_description ta
    _('removed the product %{title}') % {
      title: truncate(ta.get_name),
    }
  end

  def favorite_enterprise_description ta
    _('favorited enterprise %{title}') % {
      title: link_to(truncate(ta.get_enterprise_name), ta.get_enterprise_url),
    }
  end

end
