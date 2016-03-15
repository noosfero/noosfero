module BoxesHelper

  def insert_boxes(content)
    if controller.send(:boxes_editor?) && controller.send(:uses_design_blocks?)
      content + display_boxes_editor(controller.boxes_holder)
    else
      maybe_display_custom_element(controller.boxes_holder, :custom_header_expanded, :id => 'profile-header') +
      if controller.send(:uses_design_blocks?)
        display_boxes(controller.boxes_holder, content)
      else
        content_tag('div',
          content_tag('div',
            content_tag('div', wrap_main_content(content), :class => 'no-boxes-inner-2'),
            :class => 'no-boxes-inner-1'
          ),
          :class => 'no-boxes'
        )
      end +
      maybe_display_custom_element(controller.boxes_holder, :custom_footer_expanded, :id => 'profile-footer')
    end
  end

  def box_decorator
    @box_decorator || DontMoveBlocks
  end

  def with_box_decorator(dec, &block)
    @box_decorator = dec
    result = block.call
    @box_decorator = DontMoveBlocks

    result
  end

  def display_boxes_editor(holder)
    with_box_decorator self do
      content_tag('div', display_boxes(holder, '&lt;' + _('Main content') + '&gt;'), :id => 'box-organizer')
    end
  end

  def boxes_limit holder
    controller.send(:custom_design)[:boxes_limit] || holder.boxes_limit(controller.send(:custom_design)[:layout_template])
  end

  def display_boxes(holder, main_content)
    boxes = holder.boxes.with_position.first(boxes_limit(holder))
    content = boxes.reverse.map { |item| display_box(item, main_content) }.join("\n")
    content = main_content if (content.blank?)

    content_tag('div', content, :class => 'boxes', :id => 'boxes' )
  end

  def maybe_display_custom_element(holder, element, options = {})
    if holder.respond_to?(element)
      content_tag('div', holder.send(element), options)
    else
      ''
    end
  end

  def display_box(box, main_content)
    content_tag('div', content_tag('div', display_box_content(box, main_content), :class => 'blocks'), :class => "box box-#{box.position}", :id => "box-#{box.id}" )
  end

  def display_updated_box(box)
    with_box_decorator self do
      display_box_content(box, '&lt;' + _('Main content') + '&gt;')
    end
  end

  def display_box_content(box, main_content)
    context = { :article => @page, :request_path => request.path, :locale => locale, :params => request.params, :user => user, :controller => controller }
    box_decorator.select_blocks(box, box.blocks.includes(:box), context).map do |item|
      display_block item, main_content
    end.join("\n") + box_decorator.block_target(box)
  end

  def select_blocks box, arr, context
    arr
  end

  def display_block(block, main_content = nil)
    render :file => 'shared/block', :locals => {:block => block, :main_content => main_content, :use_cache => use_cache? }
  end

  def use_cache?
    box_decorator == DontMoveBlocks
  end

  def render_block_content(block)
    template_name = block.class.name.underscore.gsub('_block', '')
    template_filename = "#{template_name}.html.erb"
    if File.exists? Rails.root.join('app', 'views', 'blocks', template_filename)
      render :file => "blocks/#{template_name}", :locals => { :block => block }
    else
      nil
    end
  end

  def render_block_footer(block)
    template_name = block.class.name.underscore.gsub('_block', '')
    template_filename = "#{template_name}.html.erb"
    if File.exists? Rails.root.join('app', 'views', 'blocks', 'footers', template_filename)
      render :file => "blocks/footers/#{template_name}", :locals => { :block => block }
    else
      nil
    end
  end

  def display_block_content(block, main_content = nil)
    # FIXME: these conditionals should be removed after all block footer from plugins methods get refactored into helpers and views. They are a failsafe until all of them are done.
    content = nil
    if block.main?
      content = wrap_main_content(main_content)
    else
      if(block.method(:content).owner != Block)
        content = block.content()
      else
        content = render_block_content(block)
      end
    end
    result = extract_block_content(content)
    # FIXME: this ternary conditional should be removed after all block footer from plugins methods get refactored into helpers and views
    footer_content = extract_block_content(block.method(:footer).owner != Block ? block.footer : render_block_footer(block))
    unless footer_content.blank?
      footer_content = content_tag('div', footer_content, :class => 'block-footer-content' )
    end

    options = {
      :class => classes = ['block', block_css_classes(block) ].uniq.join(' '),
      :id => "block-#{block.id}"
    }
    if ( block.respond_to? 'help' )
      options[:help] = block.help
    end
    unless block.visible?
      options[:title] = _("This block is invisible. Your visitors will not see it.")
    end

    result = filter_html(result, block)

    content_tag('div',
      box_decorator.block_target(block.box, block) +
        content_tag('div',
         content_tag('div',
           content_tag('div',
             result + footer_content + box_decorator.block_edit_buttons(block),
             :class => 'block-inner-2'),
           :class => 'block-inner-1'),
       options),
    :class => 'block-outer') +
    box_decorator.block_handle(block)
  end

  def wrap_main_content(content)
    content_tag('div', content, :class => 'main-content')
  end

  def extract_block_content(content)
    case content
    when Hash
      content_tag('iframe', '', :src => url_for(content))
    when String
      if content.split("\n").size == 1 and content =~ /^https?:\/\//
        content_tag('iframe', '', :src => content)
      else
        content
      end
    when Proc
      self.instance_eval(&content)
    when NilClass
      ''
    else
      raise "Unsupported content for block (#{content.class})"
    end
  end

  module DontMoveBlocks
    # does nothing
    def self.block_target(box, block = nil)
      ''
    end
    # does nothing
    def self.block_handle(block)
      ''
    end
    def self.block_edit_buttons(block)
      ''
    end
    def self.select_blocks box, arr, context
      arr = arr.select{ |block| block.visible? context }

      custom_design = context[:controller].send(:custom_design)
      inserts = [custom_design[:insert]].flatten.compact
      inserts.each do |insert_opts|
        next unless box.position == insert_opts[:box]
        position, block = insert_opts[:position], insert_opts[:block]
        block = block.new box: box if block.is_a? Class

        if not insert_opts[:uniq] or not box.blocks.map(&:class).include? block.klass
          arr = arr.insert position, block
        end
      end

      arr
    end
  end

  # generates a place where you can drop a block and get the block moved to
  # there.
  #
  # If +block+ is not nil, then it means "place the dropped block before this
  # one.". Otherwise, it means "place the dropped block at the end of the
  # list"
  #
  # +box+ is always needed
  def block_target(box, block = nil)
    id =
      if block.nil?
        "end-of-box-#{box.id}"
      else
        "before-block-#{block.id}"
      end
    if block.nil? or movable?(block)
      url = url_for(:action => 'move_block', :target => id)
      content_tag('div', _('Drop Here'), :id => id, :class => 'block-target' ) + drop_receiving_element(id, :accept => box.acceptable_blocks, :hoverclass => 'block-target-hover', :activeClass => 'block-target-active', :tolerance => 'pointer', :onDrop => "function(ev, ui) { dropBlock('#{url}', '#{_('loading...')}', ev, ui);}")
    else
      ""
    end
  end

  # makes the given block draggable so it can be moved away.
  def block_handle(block)
    return "" unless movable?(block)
    icon = "<div><div>#{display_icon(block.class)}</div><span>#{_(block.class.pretty_name)}</span></div>"
    block_draggable("block-#{block.id}",
                    :helper => "function() {return cloneDraggableBlock($(this), '#{icon}')}")
  end

  def block_draggable(element_id, options={})
    draggable_options = {
      :revert => "'invalid'",
      :appendTo => "'#block-store-draggables'",
      :helper => '"clone"',
      :revertDuration => 200,
      :scroll => false,
      :start => "startDragBlock",
      :stop => "stopDragBlock",
      :cursor => "'move'",
      :cursorAt => '{ left: 0, top:0, right:0, bottom:0 }',
    }.merge(options)
    draggable_element(element_id, draggable_options)
  end

  def block_edit_buttons(block)
    buttons = []
    nowhere = 'javascript: return false;'

    if movable?(block)
      if block.first?
        buttons << icon_button('up-disabled', _("Can't move up anymore."), nowhere)
      else
        buttons << icon_button('up', _('Move block up'), { :action => 'move_block_up', :id => block.id }, { :method => 'post' })
      end

      if block.last?
        buttons << icon_button('down-disabled', _("Can't move down anymore."), nowhere)
      else
        buttons << icon_button(:down, _('Move block down'), { :action => 'move_block_down' ,:id => block.id }, { :method => 'post'})
      end

      holder = block.owner
      # move to opposite side
      # FIXME too much hardcoded stuff
      if holder.layout_template == 'default'
        if block.box.position == 2 # area 2, left side => move to right side
          buttons << icon_button('right', _('Move to the opposite side'), { :action => 'move_block', :target => 'end-of-box-' + holder.boxes[2].id.to_s, :id => block.id }, :method => 'post' )
        elsif block.box.position == 3 # area 3, right side => move to left side
          buttons << icon_button('left', _('Move to the opposite side'), { :action => 'move_block', :target => 'end-of-box-' + holder.boxes[1].id.to_s, :id => block.id }, :method => 'post' )
        end
      end
    end

    if editable?(block, user)
      buttons << modal_icon_button(:edit, _('Edit'), { :action => 'edit', :id => block.id })
    end

    if movable?(block) && !block.main?
      buttons << icon_button(:delete, _('Remove block'), { action: 'remove', id: block.id }, method: 'post', data: {confirm: _('Are you sure you want to remove this block?')})
      buttons << icon_button(:clone, _('Clone'), { :action => 'clone_block', :id => block.id }, { :method => 'post' })
    end

    if block.respond_to?(:help)
      buttons << modal_inline_icon(:help, _('Help on this block'), {}, "#help-on-box-#{block.id}") << content_tag('div', content_tag('h2', _('Help')) + content_tag('div', block.help, :style => 'margin-bottom: 1em;') + modal_close_button(_('Close')), :style => 'display: none;', :id => "help-on-box-#{block.id}")
    end

    if block.embedable?
      embed_code = block.embed_code
      embed_code = instance_exec(&embed_code) if embed_code.respond_to?(:call)
      html = content_tag('div',
              content_tag('h2', _('Embed block code')) +
              content_tag('div', _('Below, you''ll see a field containing embed code for the block. Just copy the code and paste it into your website or blogging software.'), :style => 'margin-bottom: 1em;') +
              content_tag('textarea', embed_code, :style => 'margin-bottom: 1em; width:100%; height:40%;', :readonly => 'readonly') +
              modal_close_button(_('Close')), :style => 'display: none;', :id => "embed-code-box-#{block.id}")
      buttons << modal_inline_icon(:embed, _('Embed code'), {}, "#embed-code-box-#{block.id}") << html
    end

    content_tag('div', buttons.join("\n") + tag('br', :style => 'clear: left'), :class => 'button-bar')
  end

  def current_blocks
    controller.boxes_holder.boxes.map(&:blocks).inject([]){|ac, a| ac + a}
  end

  # DEPRECATED. Do not use this.
  def import_blocks_stylesheets(options = {})
    @blocks_css_files ||= current_blocks.map{|block|'blocks/' + block.class.name.to_css_class}.uniq
    stylesheet_import(@blocks_css_files, options)
  end
  def block_css_classes(block)
    classes = block.class.name.to_css_class
    classes += ' invisible-block' if block.display == 'never'
    classes
  end

  def movable?(block)
    return block.movable? || user.is_admin?
  end

  def editable?(block, user=nil)
    return block.editable?(user) || user.is_admin?
  end
end
