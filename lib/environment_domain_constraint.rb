class EnvironmentDomainConstraint
  def matches?(request)
    !Domain.hosting_profile_at(request.host)
  end
end
