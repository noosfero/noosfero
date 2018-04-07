ActionDispatch::Reloader.to_param do
  ActionDispatch::Session::ActiveRecordStore.session_class = Session
end

