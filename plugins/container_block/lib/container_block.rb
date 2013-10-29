class ContainerBlock < Block

  after_create :create_box

  settings_items :container_box_id, :type => Integer, :default => nil
  settings_items :children_settings, :type => Hash, :default => {}
  
  def self.description
    _('Container')
  end

  def help
    _('This block acts as a container for another blocks')
  end
  
  def layout_template
    'default'
  end

  def create_box
    box = Box.create!(:owner => self)
    settings[:container_box_id] = box.id
    save!
  end

  def container_box
    Box.find(container_box_id)
  end

  def block_classes=(classes)
    classes.each { |c| block = c.constantize.create!(:box => container_box) } if classes
  end

  def blocks
    container_box.blocks
  end

  def child_width(child_id)
    children_settings[child_id][:width] if children_settings[child_id]
  end

  #FIXME controller test
  def content(args={})
    block = self
    lambda do
      render :file => 'blocks/container.rhtml', :locals => {:block => block}
    end
  end
  
end
