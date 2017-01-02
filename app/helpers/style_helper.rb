module StyleHelper
  def kindify_class(profile, classes)
    [classes, (profile ? profile.kinds_style_classes : nil)].compact.join(' ')
  end
end
