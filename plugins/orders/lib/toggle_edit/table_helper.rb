module ToggleEdit

  module TableHelper

    def edit_arrow anchor, toggle = true, options = {}
      content_tag 'div',
        edit_arrow_circle(anchor, toggle, options),
        class: 'box-field actions'
    end

    def edit_arrow_circle anchor, toggle, options
      options[:class] ||= ''
      options[:onclick] ||= ''
      options[:class] += ' actions-circle'
      options['toggle-edit'] = ''
      options[:onclick] = "r = sortable_table.edit_arrow_toggle(this); #{options[:onclick]}; return r;" if toggle

      link_to content_tag('div', '', :class => 'action-hide') + content_tag('div', '', :class => 'action-show'), anchor, options
    end

  end

end
