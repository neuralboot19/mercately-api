namespace :automatic_answers do
  task update_platform: :environment do
    AutomaticAnswer.find_each do |m|
      if m.status == 1
        m.destroy
        next
      end

      case m.platform
      when 0
        m.update_column(:whatsapp, true)
      when 1
        m.update_column(:messenger, true)
      when 2
        m.update_column(:instagram, true)
      end
    end
  end
end
