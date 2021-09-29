class SlackError
  def self.send_error(e)
    return if ENV['ENVIRONMENT'] != 'production' || ENV['SLACK_DEBUG'].nil?

    slack_client.ping([
      "Error: #{e.message}",
      "Backtrace: #{e.backtrace.select { |x| x.match(/app/) }}"
    ].join("\n"))
  rescue
    begin
      slack_client.ping([
        "Error: #{e}",
        "Backtrace: #{caller[0]}"
      ].join("\n"))
    rescue
      Rails.logger.error('Slack disabled')
    end
  end

  def self.slack_client
    @slack_client ||= Slack::Notifier.new ENV['SLACK_DEBUG'], channel: '#exceptions'
  end
end
