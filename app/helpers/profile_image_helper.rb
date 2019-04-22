module ProfileImageHelper
  def default_or_themed_icon(icon)
    if File.exists?(Rails.root.join('public', theme_path, icon))
      theme_path + icon
    else
      icon
    end
  end

  def gravatar_default
    (respond_to?(:theme_option) && theme_option.present? && theme_option['gravatar']) || NOOSFERO_CONF['gravatar'] || 'mm'
  end

  def profile_sex_icon( profile )
    return '' unless profile.is_a?(Person)
    return '' unless !environment.enabled?('disable_gender_icon')
    sex = ( profile.sex ? profile.sex.to_s() : 'undef' )
    title = ( sex == 'undef' ? _('non registered gender') : ( sex == 'male' ? _('Male') : _('Female') ) )
    sex = content_tag 'span',
                      content_tag( 'span', sex ),
                      :class => 'sex-'+sex,
                      :title => title
    sex
  end

  def profile_pic( profile )
    if profile.image
      filename = profile.image.public_filename
    else
      pic = if profile.organization?
        if profile.kind_of?(Community)
          '/images/icons-app/community-big.png'
        else
          '/images/icons-app/enterprise-big.png'
        end
      else
        gravatar_profile_image_url(
          profile.email,
          :size => 200,
          :d => gravatar_default
        )
      end
    end
  end

  def profile_default_image type, size=:minor
      case type
      when :person
        "/images/icons-app/person-#{size.to_s}.png"
      when :community
        "/images/icons-app/community-#{size.to_s}.png"
      when :enterprise
        "/images/icons-app/enterprise-#{size.to_s}.png"
      end
  end

  def profile_icon( profile, size=:portrait, return_mimetype=false )
    filename, mimetype = '', 'image/png'
    if profile.image.present?
      filename = profile.image.public_filename(size)
      mimetype = profile.image.content_type
    else
      size = :big if size.blank?
      icon =
        if profile.organization?
          if profile.kind_of?(Community)
            '/images/icons-app/community-'+ size.to_s() +'.png'
          else
            '/images/icons-app/enterprise-'+ size.to_s() +'.png'
          end
        else
          pixels = Image.attachment_options[:thumbnails][size.to_sym].split('x').first
          gravatar_profile_image_url(
            profile.email,
            :size => pixels,
            :d => gravatar_default
          )
        end
      filename = default_or_themed_icon(icon)
    end
    return_mimetype ? [filename, mimetype] : filename
  end

  # generates a image tag for the profile.
  #
  # If the profile has no image set yet, then a default image is used.
  def profile_image(profile, size=:portrait, opt={})
    return '' if profile.nil?
    opt[:alt]   ||= profile.name()
    opt[:title] ||= ''
    opt[:class] ||= ''
    opt[:class] += ( profile.class == Person ? ' photo' : ' logo' )
    image_tag(profile_icon(profile, size), opt )
  end

  include MembershipsHelper

  def links_for_balloon(profile)
    if environment.enabled?(:show_balloon_with_profile_links_when_clicked)
      if profile.kind_of?(Person)
        return [
          {_('Wall') => {:href => url_for(profile.public_profile_url)}},
          {_('Friends') => {:href => url_for(:controller => :profile, :action => :friends, :profile => profile.identifier)}},
          {_('Communities') => {:href => url_for(:controller => :profile, :action => :communities, :profile => profile.identifier)}},
          {_('Send an e-mail') => {:href => url_for(:profile => profile.identifier, :controller => 'contact', :action => 'new'), :class => 'send-an-email', :style => 'display: none'}},
          {_('Add') => {:href => url_for(profile.add_url), :class => 'add-friend', :style => 'display: none'}}
        ]
      elsif profile.kind_of?(Community)
        return [
          {_('Wall') => {:href => url_for(profile.public_profile_url)}},
          {_('Members') => {:href => url_for(:controller => :profile, :action => :members, :profile => profile.identifier)}},
          {_('Agenda') => {:href => url_for(:controller => :profile, :action => :events, :profile => profile.identifier)}},
          {_('Join') => {:href => url_for(profile.join_url), :class => 'join-community'+ (show_confirmation_modal?(profile) ? ' modal-toggle' : '') , :style => 'display: none'}},
          {_('Leave community') => {:href => url_for(profile.leave_url), :class => 'leave-community', :style => 'display:  none'}},
          {_('Send an e-mail') => {:href => url_for(:profile => profile.identifier, :controller => 'contact', :action => 'new'), :class => 'send-an-email', :style => 'display: none'}}
        ]
      elsif profile.kind_of?(Enterprise)
        return [
          {_('Members') => {:href => url_for(:controller => :profile, :action => :members, :profile => profile.identifier)}},
          {_('Agenda') => {:href => url_for(:controller => :profile, :action => :events, :profile => profile.identifier)}},
          {_('Send an e-mail') => {:href => url_for(:profile => profile.identifier, :controller => 'contact', :action => 'new'), :class => 'send-an-email', :style => 'display: none'}},
        ]
      end
    end
    []
  end

  include StyleHelper

  # displays a link to the profile homepage with its image (as generated by
  # #profile_image) and its name below it.
  def profile_image_link( profile, size=:portrait, tag='li', extra_info = nil )
    if content = @plugins.dispatch_first(:profile_image_link, profile, size, tag, extra_info)
      return instance_exec(&content)
    end
    name = profile.short_name
    if profile.person?
      url = url_for(profile.check_friendship_url)
      trigger_class = 'person-trigger'
    else
      city = ''
      url = url_for(profile.check_membership_url)
      if profile.community?
        trigger_class = 'community-trigger'
      elsif profile.enterprise?
        trigger_class = 'enterprise-trigger'
      end
    end

    extra_info_tag = ''

    if profile.secret?
      img_class = 'profile-image secret-profile'
    else
      img_class = 'profile-image'
    end

    if extra_info.is_a? Hash
      extra_info_tag = content_tag( 'span', extra_info[:value], :class => 'extra_info '+extra_info[:class])
      img_class +=' '+extra_info[:class]
    else
      extra_info_tag = content_tag( 'span', extra_info, :class => 'extra_info' )
    end

    links = links_for_balloon(profile) << {home: {href: url_for(profile.url)}}
    content_tag(tag,
      (
        environment.enabled?(:show_balloon_with_profile_links_when_clicked) ?
        popover_menu(
          _('Profile links'), profile.short_name, links, class: trigger_class, url: url
        ) : ""
      ).html_safe +
      link_to(
        content_tag('span', profile_image(profile, size), class: img_class, style: (
          theme_option(:profile_list_bg_imgs) ?
          "visibility:hidden;" : ''
        )) +
        content_tag('span', h(name), class: (profile.class == Person ? 'fn' : 'org'), style: (
          theme_option(:profile_list_bg_imgs) ?
          "margin-top: 1.7em;" : ''
        )) +
        extra_info_tag + profile_sex_icon(profile),
        profile.url,
        class: 'profile_link',
        style: (
          theme_option(:profile_list_bg_imgs) ?
          "background: url(#{profile_icon(profile, size)}) no-repeat center center; 
           background-size: cover;
           margin-top: 2em;" : ''
        ),
        title: profile.name ).html_safe,
      class: "vcard common-profile-list-block #{profile.image ? 'has-pic' : 'no-pic'}"
    )
  end
end
