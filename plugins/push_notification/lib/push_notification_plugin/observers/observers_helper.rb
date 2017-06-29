module PushNotificationPlugin::Observers::ObserversHelper

  def get_target_and_requestor(article)
    target = article.target, requestor = article.requestor
  end

  def get_users_info(target)
    if target.person?
      users = [target.user]
    elsif target.organization?
      users = target.admins.map{|person| person.user}
    end
  end

end
