module PermissionCheck
  protected
  # Declares the +permission+ need to be able to access +action+.
  #
  # * +action+ must be a symbol or string with the name of the action
  # * +permission+ must be a symbol or string naming the needed permission.
  # * +target+ is the object over witch the user would need the specified permission.
  def protect(actions, permission, target = nil)
    before_filter :only => actions do |c|
      unless c.send(:logged_in?) && c.send(:current_user).person.has_permission?(permission.to_s, c.send(target))
        c.send(:render, {:file => 'app/views/shared/access_denied.rhtml', :layout => true})
      end
    end
  end
end
