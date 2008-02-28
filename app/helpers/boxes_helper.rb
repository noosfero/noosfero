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
    content_tag('div', content, :class => 'boxes', :id => 'boxes' )
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
    box.blocks.map { |item| display_block(item, main_content) }.join("\n") + box_decorator.block_target(box)
  end

  def display_block(block, main_content = nil)
    content = block.main? ? main_content : block.content
    result = extract_block_content(content)
    footer_content = extract_block_content(block.footer)
    unless footer_content.blank?
      footer_content = content_tag('div', footer_content, :class => 'block-footer-content' )
    end

    options = {
      :class => classes = ['block', block.css_class_name ].uniq.join(' '),
      :id => "block-#{block.id}"
    }
    if ( block.respond_to? 'help' )
      options[:help] = block.help
    end

    box_decorator.block_target(block.box, block) +
    content_tag('div', result + footer_content + box_decorator.block_edit_buttons(block),
                options) +
    box_decorator.block_handle(block)
  end

  def extract_block_content(content)
    case content
    when Hash
      content_tag('iframe', '', :src => url_for(content))
    when String
      if content =~ /^https?:\/\//
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

    content_tag('div', '&nbsp;', :id => id, :class => 'block-target' ) + drop_receiving_element(id, :url => { :action => 'move_block', :target => id }, :accept => 'block', :hoverclass => 'block-target-hover')
  end

  # makes the given block draggable so it can be moved away.
  def block_handle(block)
    draggable_element("block-#{block.id}", :revert => true)
  end

  def block_edit_buttons(block)
    buttons = []

    buttons << icon_button(:up, _('Move block up'), { :action => 'move_block_up', :id => block.id }, { :method => 'post' }) unless block.first?
    buttons << icon_button(:down, _('Move block down'), { :action => 'move_block_down' ,:id => block.id }, { :method => 'post'}) unless block.last?
    buttons << icon_button(:delete, _('Remove block'), { :action => 'remove', :id => block.id }, { :method => 'post'}) unless block.main?

    if block.editor
      buttons << lightbox_button(:edit, _('Edit'), block.editor)
    end

    content_tag('div', buttons.join("\n") + tag('br', :style => 'clear: left'), :class => 'button-bar')
  end

  def current_blocks
    @controller.boxes_holder.boxes.map(&:blocks).flatten
  end

  def import_blocks_stylesheets
    stylesheet_import( current_blocks.map{|b|'blocks/' + b.css_class_name}.uniq ) + "\n" +
    stylesheet_import( current_blocks.map{|b|'blocks/' + b.css_class_name}.uniq, :themed_source => true )
  end

end
