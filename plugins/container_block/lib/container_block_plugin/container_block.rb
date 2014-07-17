class ContainerBlockPlugin::ContainerBlock < Block

  after_create :create_box
  after_destroy :destroy_children
  after_destroy :destroy_box

  settings_items :container_box_id, :type => Integer, :default => nil
  settings_items :children_settings, :type => Hash, :default => {}

  validate :no_cyclical_reference, :if => 'container_box_id.present?'

  def no_cyclical_reference
    errors.add(:box_id, _('cyclical reference is not allowed.')) if box_id == container_box_id
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
    container_box = Box.create!(:owner => owner)
    container_box.update_attribute(:position, nil)
    settings[:container_box_id] = container_box.id
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

end
