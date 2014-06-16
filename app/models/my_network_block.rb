class MyNetworkBlock < Block

  attr_accessible :display, :box

  def self.description
    _('My network')
  end

  def default_title
    _('My network')
  end

  def help
    _('This block displays some info about your networking.')
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/my_network', :locals => {
        :title => block.title,
        :owner => block.owner
      }
    end
  end

  def cacheable?
    false
  end

end
