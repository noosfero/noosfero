module PermissionName
  def permission_name(p)
    msgid = ActiveRecord::Base::PERMISSIONS.values.inject({}){|s,v| s.merge(v)}[p]
    gettext(msgid)
  end
end
