class LinkListBlock < Block

  include SanitizeHelper
  include LinkListBlockHelper

  attr_accessible :links

  TARGET_OPTIONS = [
    [N_('Same page'), '_self'],
    [N_('New tab'), '_blank'],
    [N_('New window'), '_new'],
  ]

  settings_items :links, type: Array, :default => []

  before_save do |block|
    block.links = block.links.delete_if {|i| i[:name].blank? and i[:address].blank?}
  end

  def self.description
    _('Links (static menu)')
  end

  def display_api_content_by_default?
    true
  end

  def api_content(params = {})
    { links: settings[:links] }
  end

  def api_content= params
    super
    settings[:links] = params[:links]
  end

  def help
    _('This block can be used to create a menu of links. You can add, remove and update the links as you wish.')
  end

  def self.pretty_name
    _('Link list')
  end

  def expand_address(address)
    add = if owner.respond_to?(:identifier)
      address.gsub('{profile}', owner.identifier)
    elsif owner.is_a?(Environment) && owner.enabled?('use_portal_community') && owner.portal_community
      address.gsub('{portal}', owner.portal_community.identifier)
    else
      address
    end
    if add !~ /^[a-z]+:\/\// && add !~ /^\//
      '//' + add
    else
      if root = Noosfero.root
        if !add.starts_with?(root)
          add = root + add
        end
      end
      add
    end
  end

end
