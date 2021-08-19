namespace :migrate do
  task tokens: :environment do
    RetailerUser.joins(:mobile_tokens)
      .where('mobile_tokens.expiration > ?', Time.now)
      .update_all('
                  api_session_token = mobile_tokens.mobile_push_token,
                  api_session_device = mobile_tokens.device,
                  api_session_expiration = mobile_tokens.expiration
                  FROM mobile_tokens
                  ')
  end
end
