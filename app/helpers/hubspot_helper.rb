module HubspotHelper
  def hs_sync_options
    [['SI', true], ['NO', false]].freeze
  end

  def hs_sync_time_options
    [['4 horas', 4], ['6 horas', 6], ['12 horas', 12], ['24 horas', 24]].freeze
  end
end
