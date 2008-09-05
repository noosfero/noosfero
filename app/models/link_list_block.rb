class LinkListBlock < Block

  settings_items :links, Array, :default => []

  before_save do |block|
    block.links = block.links.delete_if {|i| i[:name].blank? and i[:address].blank?}
  end

  def self.description
    _('Display a list of links.')
  end

  def help
    _('This block can be used to create a menu of links. You can add, remove and update the links as you wish.')
  end
  
  def content
    block_title(title) +
    content_tag('ul',
      links.select{|i| !i[:name].blank? and !i[:address].blank?}.map{|i| content_tag('li', link_to(i[:name], i[:address]))}
    )
  end

  def editable?
    true
  end

end
