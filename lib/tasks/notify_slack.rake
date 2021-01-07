namespace :notify_slack do
  task gs_templates: :environment do
    slack_client = Slack::Notifier.new ENV['SLACK_MARKETING'], channel: '#mercately-marketing'
    slack_client.ping(
      [
        'Hola equipo de Marketing tenemos:',
        "#{GsTemplate.pending.where(submitted: false).count} mensajes por enviar a Gupshup",
        "#{GsTemplate.where(submitted: true).count} por revisar su aprobación"
      ].join("\n"),
      channel: '#mercately-marketing'
    )
  end
end
