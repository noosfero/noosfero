class ContainerBlock < Block

  include Noosfero::Plugin::HotSpot

  after_create :create_box

  settings_items :container_box_id, :type => Integer, :default => nil
  
  def self.description
    _('Container')
  end

  def help
    _('This block acts as a container for another blocks')
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

  #FIXME needed?
  def layout_template
    'default2'
  end

  #FIXME controller test
  def content(args={})
    block = self
    lambda do
      render :file => 'blocks/container.rhtml', :locals => {:block => block}
    end
  end
  
end
