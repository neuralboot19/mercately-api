class SlackError
  def self.send_error(e)
    return if ENV['ENVIRONMENT'] != 'production'

    slack_client.ping([
      "Error: #{e.message}",
      "Backtrace: #{e.backtrace.select { |x| x.match(/app/) }}"
    ].join("\n"))
  rescue
    slack_client.ping([
      "Error: #{e}",
      "Backtrace: #{caller[0]}"
    ].join("\n"))
  end

  def self.slack_client
    @slack_client ||= Slack::Notifier.new ENV['SLACK_DEBUG'], channel: '#exceptions'
  end
end
