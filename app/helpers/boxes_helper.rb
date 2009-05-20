module BoxesHelper

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

  def display_boxes(holder, main_content)
    boxes = holder.boxes.first(holder.boxes_limit)
    content = boxes.reverse.map { |item| display_box(item, main_content) }.join("\n")
    content = main_content if (content.blank?)

    maybe_display_custom_element(holder, :custom_header_expanded, :id => 'profile-header') +
    content_tag('div', content, :class => 'boxes', :id => 'boxes' ) +
    maybe_display_custom_element(holder, :custom_footer_expanded, :id => 'profile-footer')
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
    box_decorator.select_blocks(box.blocks).map { |item| display_block(item, main_content) }.join("\n") + box_decorator.block_target(box)
  end

  def select_blocks(arr)
    arr
  end

  def display_block(block, main_content = nil)
    render :file => 'shared/block', :locals => {:block => block, :main_content => main_content, :use_cache => use_cache? }
  end

  def use_cache?
    box_decorator == DontMoveBlocks
  end

  def display_block_content(block, main_content = nil)
    content = block.main? ? wrap_main_content(main_content) : block.content
    result = extract_block_content(content)
    footer_content = extract_block_content(block.footer)
    unless footer_content.blank?
      footer_content = content_tag('div', footer_content, :class => 'block-footer-content' )
    end

    options = {
      :class => classes = ['block', block.css_classes ].uniq.join(' '),
      :id => "block-#{block.id}"
    }
    if ( block.respond_to? 'help' )
      options[:help] = block.help
    end
    unless block.visible?
      options[:title] = _("This block is invisible. Your visitors will not see it.")
    end

    box_decorator.block_target(block.box, block) +
    content_tag('div', result + footer_content + box_decorator.block_edit_buttons(block),
                options) +
    box_decorator.block_handle(block)
  end

  def wrap_main_content(content)
    (1..8).to_a.reverse.inject(content) { |acc,n| content_tag('div', acc, :id => 'main-content-wrapper-' + n.to_s) }
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
    def self.select_blocks(arr)
      arr.select(&:visible?)
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
    # FIXME hardcoded
    return '' if box.position == 1

    id =
      if block.nil?
        "end-of-box-#{box.id}"
      else
        "before-block-#{block.id}"
      end

    content_tag('div', '&nbsp;', :id => id, :class => 'block-target' ) + drop_receiving_element(id, :url => { :action => 'move_block', :target => id }, :accept => 'block', :hoverclass => 'block-target-hover')
  end

  # makes the given block draggable so it can be moved away.
  def block_handle(block)
    # FIXME hardcoded
    return '' if block.box.position == 1

    draggable_element("block-#{block.id}", :revert => true)
  end

  def block_edit_buttons(block)
    buttons = []
    nowhere = 'javascript: return false;'

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

    if block.editable?
      buttons << lightbox_icon_button(:edit, _('Edit'), { :action => 'edit', :id => block.id })
    end

    if !block.main?
      buttons << icon_button(:eyes, _('Toggle block visibility'), {:action => 'toggle_visibility', :id => block.id})
      buttons << icon_button(:delete, _('Remove block'), { :action => 'remove', :id => block.id }, { :method => 'post'})
    end

    if block.respond_to?(:help)
      buttons << thickbox_inline_popup_icon(:help, _('Help on this block'), "help-on-box-#{block.id}") << content_tag('div', content_tag('h2', _('Help')) + content_tag('div', block.help, :style => 'margin-bottom: 1em;') + thickbox_close_button(_('Close')), :style => 'display: none;', :id => "help-on-box-#{block.id}")
    end

    content_tag('div', buttons.join("\n") + tag('br', :style => 'clear: left'), :class => 'button-bar')
  end

  def current_blocks
    @controller.boxes_holder.boxes.map(&:blocks).inject([]){|ac, a| ac + a}
  end

  def import_blocks_stylesheets
    blocks_css_files = current_blocks.map{|b|'blocks/' + b.css_class_name}.uniq
    stylesheet_import(blocks_css_files) + "\n" +
    stylesheet_import(blocks_css_files, :themed_source => true )
  end

end
