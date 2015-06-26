ActionDispatch::Reloader.to_prepare do
  ActiveRecord::SessionStore.session_class = Session
end

