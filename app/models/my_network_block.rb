class MyNetworkBlock < Block

  include ActionController::UrlWriter

  def self.description
    _('A block that displays a summary of your network')
  end

  def default_title
    _('My network')
  end

  def help
    _('This block displays some info about your networking.')
  end

  def content
    block = self
    lambda do
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
