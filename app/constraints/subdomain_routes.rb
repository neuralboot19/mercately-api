class SubdomainRoutes
  def self.matches? request
    case request.subdomain
    when '', 'www', 'staging'
      true
    else
      false
    end
  end
end
