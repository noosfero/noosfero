if File.writable?(Rails.root)
  # create the symlink to the default theme if it does not exist
  default = File.join(RAILS_ROOT, 'public', 'designs', 'themes', 'default')
  if !File.exists?(default)
    File.symlink('noosfero', default)
  end
end
