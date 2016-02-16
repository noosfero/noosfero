require_dependency 'boxes_helper'

module BoxesHelper

  protected

  module ResponsiveMethods
    def insert_boxes(content)
      return super unless theme_responsive?

      if controller.send(:boxes_editor?) && controller.send(:uses_design_blocks?)
        content + display_boxes_editor(controller.boxes_holder)
      else
        maybe_display_custom_element(controller.boxes_holder, :custom_header_expanded, id: 'profile-header') +
          if controller.send(:uses_design_blocks?)
            display_boxes(controller.boxes_holder, content)
        else
          content_tag(:div,
                      content_tag('div',
                                  content_tag('div',
                                              content_tag('div', wrap_main_content(content), class: 'no-boxes-inner-2'),
                                              class: 'no-boxes-inner-1'
                                             ),
                                             class: 'no-boxes col-lg-12 col-md-12 col-sm-12'
                                 ),
                                 class: 'row',
                                 id: 'content')
        end +
        content_tag('div',
          maybe_display_custom_element(controller.boxes_holder, :custom_footer_expanded, id: 'profile-footer'),
          :class => 'row')
      end
    end

    def display_boxes holder, main_content
      return super unless theme_responsive?

      boxes = holder.boxes.with_position.order('boxes.position ASC').first(boxes_limit(holder))

      template = profile.nil? ? environment.layout_template : profile.layout_template
      template = 'default' if template.blank?

      return main_content unless boxes.present?
      render partial: "templates/boxes_#{template}", locals: {boxes: boxes, main_content: main_content}, use_cache: use_cache?
    end

    def display_topbox_content(box, main_content)
      context = {article: @page, request_path: request.path, locale: locale, params: request.params, controller: controller}
      box_decorator.select_blocks(box, box.blocks.includes(:box), context).map do |item|
        if item.class.name == 'LinkListBlock' and request.params[:controller] != 'profile_design'
          render_linklist_navbar(item)
        else
          display_block item, main_content
        end
      end.join("\n") + box_decorator.block_target(box)
    end

    def render_linklist_navbar link_list
      list = link_list.links.select{ |i| i[:name].present? and i[:address].present? }
      render file: 'blocks/link_list_navbar', locals: {block: link_list, links: list}
    end
  end

  include ResponsiveChecks
  if RUBY_VERSION >= '2.0.0'
    prepend ResponsiveMethods
  else
    extend ActiveSupport::Concern
    included { include ResponsiveMethods }
  end

end

