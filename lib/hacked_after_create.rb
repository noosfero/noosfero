class << ActiveRecord::Base
  # it seems that in some enviroments after_create hook is not inherited. This
  # method calls after_create only if the callback is not already there.
  def hacked_after_create(sym)
    current = after_create
    if !current.include?(sym)
      current = after_create(sym)
    end
    current
  end
end
