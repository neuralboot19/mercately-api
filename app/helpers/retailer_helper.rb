module RetailerHelper
  def timezones_list
    TZInfo::Timezone.all_country_zone_identifiers.sort
  end
end
