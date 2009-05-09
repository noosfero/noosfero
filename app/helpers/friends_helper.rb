module FriendsHelper

  def link_to_import(text, options = {})
    options.merge!({:action => 'invite', :import => 1, :wizard => true})
    link_to text, options
  end
end
