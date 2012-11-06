if File.writable?(Rails.root)
  # create the symlink to the default theme if it does not exist
  default = File.join(Rails.root, 'public', 'designs', 'themes', 'default')
  if !File.exists?(default)
    File.symlink('noosfero', default)
  end
end
