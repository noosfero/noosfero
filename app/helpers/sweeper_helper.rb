module SweeperHelper

  def expire_fragment(*args)
    ActionController::Base.new().expire_fragment(*args)
  end

  def expire_timeout_fragment(*args)
    ActionController::Base.new().expire_timeout_fragment(*args)
  end

end
