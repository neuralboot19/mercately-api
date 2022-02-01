module RetailerHelper
  def timezones_list
    TZInfo::Timezone.all_country_zone_identifiers.sort
  end

  def total_free_conversations
    1000 - current_retailer.remaining_free_conversations
  end

  def percentage_free_conversations
    total_free = 1000 - current_retailer.remaining_free_conversations
    total_free*100/1000
  end
end
