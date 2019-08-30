module ColorsHelper
  def cookie(status)
    case status
    when 'closed', 'cancelled'
      'cookie--red'
    when 'paused', 'pending'
      'cookie--yellow'
    when 'active', 'success'
      'cookie--green'
    end
  end
end
