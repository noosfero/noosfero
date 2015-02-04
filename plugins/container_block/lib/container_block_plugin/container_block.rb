class ContainerBlockPlugin::ContainerBlock < Block

  after_create :create_box
  after_destroy :destroy_children
  after_destroy :destroy_box

  settings_items :container_box_id, :type => Integer, :default => nil
  settings_items :children_settings, :type => Hash, :default => {}

  validate :no_cyclical_reference, :if => 'container_box_id.present?'

  def no_cyclical_reference
    errors.add(:box_id, c_('cyclical reference is not allowed.')) if box_id == container_box_id
  end

  before_save do |b|
    raise "cyclical reference is not allowed" if b.box_id == b.container_box_id && !b.container_box_id.blank?
  end

  def self.description
    _('Container')
  end

  def help
    _('This block acts as a container for another blocks')
  end

  def cacheable?
    false
  end

  def layout_template
    nil
  end

  def destroy_children
    blocks.destroy_all
  end

  def create_box
    container_box = Box.new(:owner => owner)
    container_box.save!
    settings[:container_box_id] = container_box.id
    copy_blocks unless @blocks_to_copy.blank?
    container_box.update_attribute(:position, nil)
    save!
  end

  def destroy_box
    container_box.destroy
  end

  def container_box
    owner.boxes.find(container_box_id)
  end

  def block_classes=(classes)
    classes.each { |c| block = c.constantize.create!(:box_id => container_box.id) } if classes
  end

  def blocks
    container_box.blocks
  end

  def child_width(child_id)
    children_settings[child_id][:width] if children_settings[child_id]
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/container', :locals => {:block => block}
    end
  end

  def copy_from_with_container(block)
    copy_from_without_container(block)
    children_settings = block.children_settings
    @blocks_to_copy = block.blocks
  end

  alias_method_chain :copy_from, :container

  def copy_blocks
    new_children_settings = {}
    @blocks_to_copy.map do |child|
      new_block = child.class.new(:title => child[:title])
      new_block.copy_from(child)
      container_box.blocks << new_block
      new_children_settings[new_block.id] = children_settings[child.id] if children_settings[child.id]
    end
    settings[:children_settings] = new_children_settings
  end

end
