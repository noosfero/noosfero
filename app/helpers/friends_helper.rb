module FriendsHelper

  def link_to_import(text, options = {})
    options.merge!({:action => 'invite', :import => 1, :wizard => true})
    link_to text, options
  end

  def pagination_links(collection, options={})
    options = {:prev_label => '&laquo; ' + _('Previous'), :next_label => _('Next') + ' &raquo;'}.merge(options)
    will_paginate(collection, options)
  end

end
