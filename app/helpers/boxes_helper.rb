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
    content_tag('div', content_tag('div', display_box_content(box, main_content), :class => 'blocks'), :class => 'box', :id => "box-#{box.position}" )
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
    content = block.content(main_content)
    result = 
      case content
      when Hash
        content_tag('iframe', '', :src => url_for(content))
      when String
        if content =~ /^https?:\/\//
          content_tag('iframe', '', :src => content)
        else
          content
        end
      end

    classes = ['block', block.class.name.underscore.gsub('_', '-') ].uniq.join(' ')

    box_decorator.block_target(block.box, block) + content_tag('div', result + box_decorator.block_move_buttons(block), :class => classes, :id => "block-#{block.id}") + box_decorator.block_handle(block)
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
    def self.block_move_buttons(block)
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

  def block_move_buttons(block)
    buttons = []

    # FIXME hardcoded paths !!!
    buttons << link_to(image_tag('/designs/icons/default/gtk-go-up.png', :alt => _('Move block up')), { :action => 'move_block_up', :id => block.id }, { :method => 'post' }) unless block.first?
    buttons << link_to(image_tag('/designs/icons/default/gtk-go-down.png', :alt => _('Move block down')), { :action => 'move_block_down' ,:id => block.id }, { :method => 'post'}) unless block.last?

    content_tag('div', buttons.join("\n"), :class => 'block-move-buttons')
  end

end
