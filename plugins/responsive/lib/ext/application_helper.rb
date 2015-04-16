require_dependency 'application_helper'
require_relative 'input_helper'

module ApplicationHelper

  extend ActiveSupport::Concern
  protected

  module ResponsiveMethods
    FORM_CONTROL_CLASS = "form-control"

    def button(type, label, url, html_options = {})
      return super unless theme_responsive?

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      the_class = "with-text btn btn-#{size} btn-#{option} icon-#{type}"
      if html_options.has_key?(:class)
        the_class << ' ' << html_options[:class]
      end
      #button_without_text type, label, url, html_options.merge(:class => the_class)
      the_title = html_options[:title] || label
      if html_options[:disabled]
        content_tag('a', content_tag('span', label), html_options.merge(class: the_class, title: the_title))
      else
        link_to(content_tag('span', label), url, html_options.merge(class: the_class, title: the_title))
      end
    end

    def button_without_text(type, label, url, html_options = {})
      return super unless theme_responsive?

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      the_class = "btn btn-#{size} btn-#{option} icon-#{type}"
      if html_options.has_key?(:class)
        the_class << ' ' << html_options[:class]
      end
      the_title = html_options[:title] || label
      if html_options[:disabled]
        content_tag('a', '', html_options.merge(class: the_class, title: the_title))
      else
        link_to('', url, html_options.merge(class: the_class, title: the_title))
      end
    end

    def button_to_function(type, label, js_code, html_options = {}, &block)
      return super unless theme_responsive?

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      html_options[:class] = "btn btn-#{size} btn-#{option} with-text #{html_options[:class]}"
      html_options[:class] << " icon-#{type}"
      link_to_function(label, js_code, html_options, &block)
    end

    def button_to_function_without_text(type, label, js_code, html_options = {}, &block)
      return super unless theme_responsive?
      html_options[:title] ||= label
      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      html_options[:class] = "" unless html_options[:class]
      html_options[:class] << " btn btn-#{size} btn-#{option} icon-#{type}"
      link_to_function('', js_code, html_options, &block)
    end

    def button_to_remote(type, label, options, html_options = {})
      return super unless theme_responsive?
      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      html_options[:class] = "btn btn-#{size} btn-#{option} with-text" unless html_options[:class]
      html_options[:class] << " icon-#{type}"
      link_to_remote(label, options, html_options)
    end

    def button_to_remote_without_text(type, label, options, html_options = {})
      return super unless theme_responsive?

      html_options[:title] ||= label
      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      html_options[:class] = "" unless html_options[:class]
      html_options[:class] << " btn btn-#{size} btn-#{option} icon-#{type}"
      link_to_remote(content_tag('span', label), options, html_options.merge(title: label))
    end

    def icon(icon_name, html_options = {})
      return super unless theme_responsive?

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      the_class = "btn btn-#{size} btn-#{option} #{icon_name}"
      if html_options.has_key?(:class)
        the_class << ' ' << html_options[:class]
      end
      content_tag('div', '', html_options.merge(class: the_class))
    end

    def icon_button(type, text, url, html_options = {})
      return super unless theme_responsive?

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      the_class = "btn btn-#{size} btn-#{option} icon-button icon-#{type}"
      if html_options.has_key?(:class)
        the_class << ' ' << html_options[:class]
      end

      link_to(content_tag('span', text), url, html_options.merge(class: the_class, title: text))
    end

    def button_bar(options = {}, &block)
      return super unless theme_responsive?

      options[:class].nil? ?
          options[:class]='button-bar' :
          options[:class]+=' button-bar'
      concat(content_tag('div', capture(&block).to_s + tag('br', style: 'clear: left;'), options))
    end

    def expirable_button(content, action, text, url, html_options = {})
      return super unless theme_responsive?

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      html_options[:class] = ["btn btn-#{size} btn-#{option} with-text icon-#{action.to_s}", html_options[:class]].compact.join(' ')
      expirable_content_reference content, action, text, url, html_options
    end

    def search_contents_menu
      return super unless theme_responsive?

      host = environment.default_hostname

      output = '<li class="dropdown">'
      output += link_to(_('Contents'), '#', :class=>"dropdown-toggle icon-menu-articles", title: _('Contents'), :'data-toggle'=>"dropdown", :'data-hover'=>"dropdown")
      output += '<ul class="dropdown-menu" role="menu">'

      output += '<li>' + link_to(_('All contents'), {host: host, controller: "search", action: 'contents', category_path: ''}) + '</li>'

      links = [
        {s_('contents|More recent') => {:href => url_for({host: host, :controller => 'search', :action => 'contents', :filter => 'more_recent'})}},
        {s_('contents|More viewed') => {:href => url_for({host: host, :controller => 'search', :action => 'contents', :filter => 'more_popular'})}},
        {s_('contents|Most commented') => {:href => url_for({host: host, :controller => 'search', :action => 'contents', :filter => 'more_comments'})}}
      ]
      if logged_in?
        links.push(_('New content') => modal_options({href: url_for({controller: 'cms', action: 'new', profile: current_user.login, cms: true})}))
      end

      links.each do |link|
        link.each do |name, options|
          output += content_tag(:li,content_tag(:a,name,options))
        end
      end

      output += '</ul>'
      output += '</li>'
      output
    end

    def search_people_menu
      return super unless theme_responsive?

      host = environment.default_hostname

      output = '<li class="dropdown">'
      output += link_to(_('People'), '#', :class=>"dropdown-toggle icon-menu-people", title: _('People'), :'data-toggle'=>"dropdown", :'data-hover'=>"dropdown")
      output += '<ul class="dropdown-menu" role="menu">'

      output += '<li>' + link_to(_('All people'), {host: host, controller: "search", action: 'people', category_path: ''}) + '</li>'

      links = [
        {s_('people|More recent') => {:href => url_for({host: host, :controller => 'search', :action => 'people', :filter => 'more_recent'})}},
        {s_('people|More active') => {:href => url_for({host: host, :controller => 'search', :action => 'people', :filter => 'more_active'})}},
        {s_('people|More popular') => {:href => url_for({host: host, :controller => 'search', :action => 'people', :filter => 'more_popular'})}}
      ]
      if logged_in?
        links.push(_('My friends') => {href: url_for({profile: current_user.login, controller: 'friends'})})
        links.push(_('Invite friends') => {href: url_for({profile: current_user.login, controller: 'invite', action: 'friends'})})
      end

      links.each do |link|
        link.each do |name, url|
          output += '<li><a href="'+url[:href]+'">' + name + '</a></li>'
        end
      end

      output += '</ul>'
      output += '</li>'
      output
    end

    def search_communities_menu
      return super unless theme_responsive?

      host = environment.default_hostname

      output = '<li class="dropdown">'
      output += link_to(_('Communities'), '#', :class=>"dropdown-toggle icon-menu-community", title: _('Communities'), :'data-toggle'=>"dropdown", :'data-hover'=>"dropdown")
      output += '<ul class="dropdown-menu" role="menu">'

      output += '<li>' + link_to(_('All communities'), {host: host, controller: "search", action: 'communities', category_path: ''}) + '</li>'

      links = [
        {s_('communities|More recent') => {:href => url_for({host: host, :controller => 'search', :action => 'communities', :filter => 'more_recent'})}},
        {s_('communities|More active') => {:href => url_for({host: host, :controller => 'search', :action => 'communities', :filter => 'more_active'})}},
        {s_('communities|More popular') => {:href => url_for({host: host, :controller => 'search', :action => 'communities', :filter => 'more_popular'})}}
      ]
      if logged_in?
        links.push(_('My communities') => {href: url_for({profile: current_user.login, controller: 'memberships'})})
        links.push(_('New community') => {href: url_for({profile: current_user.login, controller: 'memberships', action: 'new_community'})})
      end

      links.each do |link|
        link.each do |name, url|
          output += '<li><a href="'+url[:href]+'">' + name + '</a></li>'
        end
      end

      output += '</ul>'
      output += '</li>'
      output
    end

    def usermenu_logged_in
      return super unless theme_responsive?

      output = '<li class="dropdown">'

      pending_tasks_count = ''
      count = user ? Task.to(user).pending.count : -1
      if count > 0
        pending_tasks_count = "<span class=\"badge\" onclick=\"document.location='#{url_for(user.tasks_url)}'\" title=\"#{_("Manage your pending tasks")}\">" + count.to_s + '</span>'
      end

      output += link_to("<img class=\"menu-user-gravatar\" src=\"#{user.profile_custom_icon(gravatar_default)}\"><strong>#{user.identifier}</strong> #{pending_tasks_count}", '#', id: "homepage-link", title: _('Go to your homepage'), :class=>"dropdown-toggle", :'data-toggle'=>"dropdown", :'data-target'=>"", :'data-hover'=>"dropdown")


      output += '<ul class="dropdown-menu" role="menu">'
      output += '<li>' + link_to('<span class="icon-person">'+_('Profile')+'</span>', user.public_profile_url, id: "homepage-link", title: _('Go to your homepage')) + '</li>'

      output += '<li class="divider"></li>'

      #TODO
      #render_environment_features(:usermenu) +

      #admin_link
      admin_link_str = admin_link
      output += admin_link_str.present? ? '<li>' + admin_link_str + '</li>' : ''

      #control_panel link
      output += '<li>' + link_to('<i class="icon-menu-ctrl-panel"></i><strong>' + _('Control panel') + '</strong>', user.admin_url, class: 'ctrl-panel', title: _("Configure your personal account and content")) + '</li>'

      #manage_enterprises
      manage_enterprises_str = manage_enterprises
      output += manage_enterprises_str.present? ? '<li>' + manage_enterprises_str + '</li>' : ''

      #manage_communities
      manage_communities_str = manage_communities
      output += manage_communities_str.present? ? '<li>' + manage_communities_str + '</li>' : ''

      output += '<li class="divider"></li>'

      output += '<li>' + link_to('<i class="icon-menu-logout"></i><strong>' + _('Logout') + '</strong>', { controller: 'account', action: 'logout'} , id: "logout", title: _("Leave the system")) + '</li>'

      output += '</ul>'
      output
    end

    def manage_link(list, kind, title)
      return super unless theme_responsive?

      if list.present?
        link_to_all = nil
        if list.count > 5
          list = list.first(5)
          link_to_all = link_to(content_tag('strong', _('See all')), :controller => 'memberships', :profile => user.identifier)
        end
        link = list.map do |element|
          link_to(content_tag('strong', element.short_name(25)), element.admin_url, :class => "icon-menu-"+element.class.identification.underscore, :title => _('Manage %s') % element.short_name)
        end
        if link_to_all
          link << link_to_all
        end
        content_tag('li', nil, class: 'divider') +
        content_tag('li', title, class: 'dropdown-header') +
        link.map{ |l| content_tag 'li', l }.join
      end
    end

    def popover_menu title,menu_title,links,html_options={}
      return super unless theme_responsive?

      menu_content = ""
      first = true
      links.each do |link|
        if link[:link].present?
          menu_content += link[:link]
        else
          link.each do |link_label , html_options|
            unless html_options[:style].present? and html_options[:style] =~ /display *: *none/
              menu_content << '<br/>' unless first
              first = false
              menu_content << content_tag(:a,link_label,html_options)
            end
          end
        end
      end

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'xs'
      "<button class='btn btn-#{size} btn-#{option} btn-popover-menu icon-parent-folder' data-toggle='popover' data-html='true' data-placement='top' data-trigger='focus' data-content=\""+CGI::escapeHTML(menu_content)+'" data-title="'+menu_title+'"></button>'
    end


    def tag(name, options = nil, open = false, escape = true)
      return super unless theme_responsive?

      # Call the original tag method to do the real work
      field_html = super

      field_html =~ /\A[^>]* type=['"]([^'"]*)['"]/
      field_html =~ /\A<(\w*)/ unless $1
      field_type = $1

      if %w(text email number password select textarea url).include? field_type
        field_html =~ /\A[^>]* class=['"]([^'"]*)['"]/
        if $1
          field_html = field_html.sub $1, $1+" #{FORM_CONTROL_CLASS}"
        else
          field_html =~ /\A(<\w*)/
          field_html = field_html.sub $1, $1+" class='#{FORM_CONTROL_CLASS}' "
        end
      end

      field_html
    end

    def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
      return super unless theme_responsive?

      # Call the original tag method to do the real work
      field_html = super

      field_html =~ /\A[^>]* type=['"]([^'"]*)['"]/
      field_html =~ /\A<(\w*)/ unless $1
      field_type = $1

      if %w(text email number password select textarea url).include? field_type
        field_html =~ /\A[^>]* class=['"]([^'"]*)['"]/
        if $1
          field_html = field_html.sub $1, $1+" #{FORM_CONTROL_CLASS}"
        else
          field_html =~ /\A(<\w*)/
          field_html = field_html.sub $1, $1+" class='#{FORM_CONTROL_CLASS}' "
        end
      end

      field_html
    end

    def labelled_form_for(name, options = {}, &proc)
      return super unless theme_responsive?

      if options[:horizontal]
        options[:html] = {} unless options[:html]
        options[:html][:class] = "" unless options[:html][:class]
        options[:html][:class] << " form-horizontal"
      end
      form_for(name, { builder: NoosferoFormBuilder }.merge(options), &proc)
    end

  # TODO: Make optional fields compliant to horizontal form
  #  def optional_field profile, name, field_html = nil, only_required = false, &block
  #  end

  end

  include ResponsiveChecks
  included do
    include ResponsiveMethods
  end

  # TODO: apply theme_responsive? condition
  class NoosferoFormBuilder

    def self.output_field text, field_html, field_id = nil, options={}
      # try to guess an id if none given
      if field_id.nil?
        field_html =~ /\A[^>]* id=['"]([^'"]*)['"]/
        field_id = $1
      end
      field_html =~ /\A[^>]* type=['"]([^'"]*)['"]/
      field_html =~ /\A<(\w*)/ unless $1
      field_type = $1

      if %w(text email number password select textarea url).include? field_type
        field_html =~ /\A[^>]* class=['"]([^'"]*)['"]/
        if $1
          field_html = field_html.sub $1, $1+" #{ApplicationHelper::ResponsiveMethods::FORM_CONTROL_CLASS}"
        else
          field_html =~ /\A(<\w*)/
          if $1
            field_html = field_html.sub $1, $1+" class='#{ApplicationHelper::ResponsiveMethods::FORM_CONTROL_CLASS}' "
          end
        end
      end

      if options[:horizontal]
        label_html = content_tag :label, gettext(text), class: 'control-label col-sm-3 col-md-2 col-lg-2', for: field_id
        result = content_tag :div, label_html + content_tag('div',field_html, class: 'col-sm-9 col-md-6 col-lg-6'), class: 'form-group'
      else
        label_html = content_tag :label, gettext(text), class: 'control-label', for: field_id
        result = content_tag :div, label_html + field_html, class: 'form-group'
      end

      result
    end
  end

end

