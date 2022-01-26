namespace :cloudinary do
  task delete_gupshup_assets_final: :environment do
    date = 6.weeks.ago.beginning_of_day
    delete_data(date)
  end

  task delete_gupshup_assets_sixmonths: :environment do
    date = 6.months.ago.beginning_of_day
    delete_data(date)
  end

  task delete_gupshup_assets_mercatelytest: :environment do
    next if ENV['ENVIRONMENT'] != 'staging'

    delete_data_by_retailer(12)
  end

  task delete_gupshup_assets_mercatelyusa: :environment do
    delete_data_by_retailer(621)
  end

  task :delete_gupshup_assets_by_id, [:retailer_id] => :environment do |t, args|
    delete_data_by_retailer(args[:retailer_id])
  end

  task :delete_gupshup_assets_by_id_and_range, [:retailer_id] => :environment do |t, args|
    start_date = 6.weeks.ago.beginning_of_day
    end_date = (start_date + 1.week).end_of_day
    delete_data_by_retailer_and_range(args[:retailer_id], start_date, end_date)
  end

  task delete_gupshup_assets_by_range: :environment do
    start_date = 6.weeks.ago.beginning_of_day
    end_date = (start_date + 1.week).end_of_day
    delete_data_by_range(start_date, end_date)
  end

  task delete_gupshup_assets: :environment do
    date = 6.weeks.ago
    start_date = date.beginning_of_day
    end_date = date.end_of_day

    retailers = Retailer.where('created_at <= ? AND delete_assets = TRUE', end_date)
                        .where.not(gupshup_phone_number: nil, gupshup_src_name: nil)

    retailers.find_each do |r|
      @asset_keys = get_asset_keys(r)
      filenames = []

      r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
        "message_payload ->> 'type' = 'image'", start_date, end_date)
        .find_in_batches(batch_size: 100) do |messages|
          filenames = get_filenames(messages, 'image')
          filenames -= @asset_keys
          delete_assets(filenames, 'image') if filenames.present?
      end

      r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
        "message_payload ->> 'type' = 'file'", start_date, end_date)
        .find_in_batches(batch_size: 100) do |messages|
          filenames = get_filenames(messages, 'file')
          filenames -= @asset_keys
          delete_assets(filenames, 'raw') if filenames.present?
      end

      r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
        "message_payload ->> 'type' IN ('audio', 'video')", start_date, end_date)
        .find_in_batches(batch_size: 100) do |messages|
          filenames = get_filenames(messages, 'video')
          filenames -= @asset_keys
          delete_assets(filenames, 'video') if filenames.present?
      end
    end
  end
end

def delete_assets(public_ids, resource_type)
  Cloudinary::Api.delete_resources(public_ids, resource_type: resource_type)
rescue Cloudinary::Api::BadRequest => e
  Rails.logger.error(e)
  SlackError.send_error(e)
  Raven.capture_exception(e)
end

def delete_data(date)
  retailers = Retailer.where('created_at < ? AND delete_assets = TRUE', date)
                      .where.not(gupshup_phone_number: nil, gupshup_src_name: nil)

  retailers.find_each do |r|
    @asset_keys = get_asset_keys(r)
    filenames = []

    r.gupshup_whatsapp_messages.where("created_at < ? AND direction = 'outbound' AND " \
      "message_payload ->> 'type' = 'image'", date)
      .find_in_batches(batch_size: 100) do |messages|
        filenames = get_filenames(messages, 'image')
        filenames -= @asset_keys
        delete_assets(filenames, 'image') if filenames.present?
    end

    r.gupshup_whatsapp_messages.where("created_at < ? AND direction = 'outbound' AND " \
      "message_payload ->> 'type' = 'file'", date)
      .find_in_batches(batch_size: 100) do |messages|
        filenames = get_filenames(messages, 'file')
        filenames -= @asset_keys
        delete_assets(filenames, 'raw') if filenames.present?
    end

    r.gupshup_whatsapp_messages.where("created_at < ? AND direction = 'outbound' AND " \
      "message_payload ->> 'type' IN ('audio', 'video')", date)
      .find_in_batches(batch_size: 100) do |messages|
        filenames = get_filenames(messages, 'video')
        filenames -= @asset_keys
        delete_assets(filenames, 'video') if filenames.present?
    end
  end
end

def delete_data_by_retailer(retailer_id)
  date = 6.weeks.ago.beginning_of_day
  r = Retailer.find_by_id(retailer_id)
  return if r.blank? || r.delete_assets == false

  @asset_keys = get_asset_keys(r)
  filenames = []

  r.gupshup_whatsapp_messages.where("created_at < ? AND direction = 'outbound' AND " \
    "message_payload ->> 'type' = 'image'", date)
    .find_in_batches(batch_size: 100) do |messages|
      filenames = get_filenames(messages, 'image')
      filenames -= @asset_keys
      delete_assets(filenames, 'image') if filenames.present?
  end

  r.gupshup_whatsapp_messages.where("created_at < ? AND direction = 'outbound' AND " \
    "message_payload ->> 'type' = 'file'", date)
    .find_in_batches(batch_size: 100) do |messages|
      filenames = get_filenames(messages, 'file')
      filenames -= @asset_keys
      delete_assets(filenames, 'raw') if filenames.present?
  end

  r.gupshup_whatsapp_messages.where("created_at < ? AND direction = 'outbound' AND " \
    "message_payload ->> 'type' IN ('audio', 'video')", date)
    .find_in_batches(batch_size: 100) do |messages|
      filenames = get_filenames(messages, 'video')
      filenames -= @asset_keys
      delete_assets(filenames, 'video') if filenames.present?
  end
end

def delete_data_by_retailer_and_range(retailer_id, start_date, end_date)
  r = Retailer.find_by_id(retailer_id)
  return if r.blank? || r.delete_assets == false

  @asset_keys = get_asset_keys(r)

  r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
    "message_payload ->> 'type' = 'image'", start_date, end_date)
    .find_in_batches(batch_size: 100) do |messages|
      filenames = get_filenames(messages, 'image')
      filenames -= @asset_keys
      delete_assets(filenames, 'image') if filenames.present?
  end

  r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
    "message_payload ->> 'type' = 'file'", start_date, end_date)
    .find_in_batches(batch_size: 100) do |messages|
      filenames = get_filenames(messages, 'file')
      filenames -= @asset_keys
      delete_assets(filenames, 'raw') if filenames.present?
  end

  r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
    "message_payload ->> 'type' IN ('audio', 'video')", start_date, end_date)
    .find_in_batches(batch_size: 100) do |messages|
      filenames = get_filenames(messages, 'video')
      filenames -= @asset_keys
      delete_assets(filenames, 'video') if filenames.present?
  end
end

def delete_data_by_range(start_date, end_date)
  retailers = Retailer.where('created_at < ? AND delete_assets = TRUE', end_date)
                      .where.not(gupshup_phone_number: nil, gupshup_src_name: nil)

  retailers.find_each do |r|
    @asset_keys = get_asset_keys(r)

    r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
      "message_payload ->> 'type' = 'image'", start_date, end_date)
      .find_in_batches(batch_size: 100) do |messages|
        filenames = get_filenames(messages, 'image')
        filenames -= @asset_keys
        delete_assets(filenames, 'image') if filenames.present?
    end

    r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
      "message_payload ->> 'type' = 'file'", start_date, end_date)
      .find_in_batches(batch_size: 100) do |messages|
        filenames = get_filenames(messages, 'file')
        filenames -= @asset_keys
        delete_assets(filenames, 'raw') if filenames.present?
    end

    r.gupshup_whatsapp_messages.where("created_at >= ? AND created_at <= ? AND direction = 'outbound' AND " \
      "message_payload ->> 'type' IN ('audio', 'video')", start_date, end_date)
      .find_in_batches(batch_size: 100) do |messages|
        filenames = get_filenames(messages, 'video')
        filenames -= @asset_keys
        delete_assets(filenames, 'video') if filenames.present?
    end
  end
end

def get_filenames(messages, type)
  filenames = messages.map do |mess|
    url = if type == 'image'
            mess.try(:[], 'message_payload').try(:[], 'originalUrl')
          else
            mess.try(:[], 'message_payload').try(:[], 'url')
          end

    next unless url.present?

    filename = url.split('/').last
    original_filename = filename.dup if type == 'file'
    splitted = filename.split('.')
    # Si tiene un solo elemento el array se asigna, sino se concatena con puntos.
    filename = if splitted[-2].nil?
                 splitted[0]
               else
                 splitted[0..-2].join('.')
               end

    filename = original_filename if type == 'file' && !filename.in?(@asset_keys)
    filename.present? ? CGI.unescape(filename) : filename
  end

  filenames.compact
end

def get_asset_keys(retailer)
  asset_keys = retailer.avatar.attached? ? [retailer.avatar.blob_id] : []

  if Product.unscoped.where(retailer_id: retailer.id).exists?
    asset_keys += ActiveStorage::Blob.joins(:attachments)
      .where(active_storage_attachments:
      {
        name: 'images',
        record_type: 'Product',
        record_id: Product.unscoped.where(retailer_id: retailer.id).ids
      }).pluck(:key)
  end

  if retailer.chat_bots.exists?
    asset_keys += ActiveStorage::Blob.joins(:attachments)
      .where(active_storage_attachments:
      {
        name: 'file',
        record_type: 'ChatBotOption',
        record_id: ChatBotOption.joins(:chat_bot).where(chat_bots: { retailer_id: retailer.id }).ids
      }).pluck(:key)

    asset_keys += ActiveStorage::Blob.joins(:attachments)
      .where(active_storage_attachments:
      {
        name: 'file',
        record_type: 'AdditionalBotAnswer',
        record_id: AdditionalBotAnswer.joins(chat_bot_option: :chat_bot)
          .where(chat_bots: { retailer_id: retailer.id }).ids
      }).pluck(:key)
  end

  if retailer.templates.exists?
    asset_keys += ActiveStorage::Blob.joins(:attachments)
      .where(active_storage_attachments:
      {
        name: 'image',
        record_type: 'Template',
        record_id: retailer.templates.ids
      }).pluck(:key)

    asset_keys += ActiveStorage::Blob.joins(:attachments)
      .where(active_storage_attachments:
      {
        name: 'file',
        record_type: 'AdditionalFastAnswer',
        record_id: AdditionalFastAnswer.joins(:template).where(templates: { retailer_id: retailer.id }).ids
      }).pluck(:key)
  end

  if retailer.reminders.exists?
    asset_keys += ActiveStorage::Blob.joins(:attachments)
      .where(active_storage_attachments:
      {
        name: 'file',
        record_type: 'Reminder',
        record_id: retailer.reminders.ids
      }).pluck(:key)
  end

  if retailer.campaigns.exists?
    asset_keys += ActiveStorage::Blob.joins(:attachments)
      .where(active_storage_attachments:
      {
        name: 'file',
        record_type: 'Campaign',
        record_id: retailer.campaigns.ids
      }).pluck(:key)
  end

  asset_keys.flatten.compact
end
