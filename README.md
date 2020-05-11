# Mercately  
[![Maintainability](https://api.codeclimate.com/v1/badges/439ed5a23d7af6e1d4da/maintainability)](https://codeclimate.com/repos/5d94b45a3bf77409dc002e04/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/439ed5a23d7af6e1d4da/test_coverage)](https://codeclimate.com/repos/5d94b45a3bf77409dc002e04/test_coverage)

## Setting up the environment

Our environment:
* Ruby 2.5.3
* Rails 5.2.2
* PostgreSQL 11.1

## Run the project locally

After installing all the required technologies pointed in the block above. You need to execute the
following commands, each one in a different terminal:

* `SCOUT_DEV_TRACE=true rails s` (execute Puma server along with scout gem to measure requests duration)
* `node server.js` (execute the server for nodejs)
* `./bin/webpack-dev-server` (execute webpacker)
* `bundle exec sidekiq` (execute sidekiq for background jobs)

## Branch naming convention
Please use one of these four prefixes for branch names: `feature/`, `test/`, `refactor/`, and `bug/`

## Setup

#### MercadoLibre (ML):
To run this project you should not need ML keys, but surely you will need to work with, so to get your own ML key follow these steps:
- Sign up and download [ngrok](https://ngrok.com/download)
- Exec `./ngrok http 3000` (You will need to do this ever you start your computer)
- Go to [ML developers portal](https://developers.mercadolibre.com.ec/), make an account, after that click in your profile icon and select `My applications`
- In `Auth and security` put `https://[your ngrok subdomain].ngrok.io/retailers/integrations/mercadolibre`
- Check all `Scopes` except `orders` and `created_orders`, because we are working with `orders_v2`
- In `Notification's settings` write `https://[your ngrok subdomain].ngrok.io/retailers/callbacks`
![Your configs should looks like this](https://i.imgur.com/gbFD0v9.png)
- Copy `.env.sample` file into `.env`
- Copy your ngrok domain and paste in `.env` file
- Copy your `App ID` and `Secret Key` and paste in `.env` file

#### Cloudinary:
For your local environment you will not need config this, but maybe you will need to work with it
- Sign up in [Cloudinary](https://cloudinary.com)
- Copy your `Cloud name`, `API Key` and `API Secret` into `.env` file
- Go to `config/environments/development.rb` file and change:
```ruby
config.active_storage.service = :local
```
to
```ruby
config.active_storage.service = :cloudinary
```

#### WhatsApp (Karix)
In order to use the WhatsApp integration in development mode with Karix, you need to follow the next steps:

- Sign up and download [ngrok](https://ngrok.com/download)
- Exec `./ngrok http 3000`
- Sign up on [Karix](https://www.karix.io/)
- Set in the retailer that you use for testing these two attributes in the database: `karix_account_uid={your Karix ACCOUNT ID}`, and `karix_account_token={your Karix ACCOUNT TOKEN}`. These two values can be found in your Karix dashboard after signing up|in.
- Edit your Retailer and update these two attributes: `whats_app_enabled` set to `true`, and `karix_whatsapp_phone` set to the sandbox phone number provided and specified in the Karix Dashboard, let's say `+13253077759`, for instance
- In your Karix dashboard, put the following URL in the text input besides the button `Edit Webhook URL` and click it later, `https://[your ngrok subdomain].ngrok.io/api/v1/karix_whatsapp?account_id={your Retailer ID}`
- Copy to your `.env` file the next variable: `KARIX_WEBHOOK={https://[your ngrok subdomain].ngrok.io/api/v1/karix_whatsapp}`
- In your cellphone, save this number `+13253077759`
- To join your Karix sandbox account, you have to send a whatsapp message, to the number saved in the past step, with the text indicated in your Karix dashboard, for example, something like this: `join generic-crayfish`. In general, that's the structure of the message, what changes between accounts is the last part of it, i.e: `join xxxxx-xxxxxx`. You should receive an answer with the text that you are already part of the sandbox.

#### Facebook Messenger
In order to use the Messenger integration in development mode, you need to follow the next steps:

- Sign up and download [ngrok](https://ngrok.com/download)
- Exec `./ngrok http 3000`
- Create a page on your facebook account, also known as fanpage
- Sign up on [facebook for developers](https://developers.facebook.com/)
- Click on `My Apps` and go to `Create App`
- Type a Display Name and Click `Create App ID`
- Go to `Settings` -> `Basic` in the left sidebar and copy to your `.env` file the next variables: `FACEBOOK_APP_ID={ID of your Facebook App}`, and `FACEBOOK_APP_SECRET={App Secret of your Facebook App}`.
- In the same view of the past step, put in the text input `App Domains` this: `[your ngrok subdomain].ngrok.io`
- In the same view, scroll down and click `Add Platform` and select in the modal `Website`. Put in the text input `Site URL` this `https://[your ngrok subdomain].ngrok.io/` and finally click `Save Changes`
- Go to `Dashboard` in the left sidebar and in the section `Add a Product`, click `Set Up` on the `Facebook Login` option.
- Go to `Facebook Login` -> `Settings` in the left sidebar, in the text input `Valid OAuth Redirect URIs` put `https://[your ngrok subdomain].ngrok.io/auth/facebook/callback` and click `Save Changes`
- Go back to `Dashboard`, go to the section `Add a Product`, and click `Set Up` on the `Webhooks` option.
- Select the option `Page` from the list, in the view shown after the past step, or clicking in the sidebar `Webhooks`, and click the button `Subscribe to this object`
- In the modal, put this `https://[your ngrok subdomain].ngrok.io/retailers/messenger_callbacks` in the text input `Callback URL` and put this `3388c56076ff02f0463f9b605958fa961e4457148586c791ccc0b04b3920c58e` in the text input `Verify Token` and click `Verify and Save`
- Copy to your `.env` file this variable: `FACEBOOK_VERIFY_TOKEN=3388c56076ff02f0463f9b605958fa961e4457148586c791ccc0b04b3920c58e`
- Go back to `Dashboard`, go to the section `Add a Product`, and click `Set Up` on the `Messenger` option.
- In the view shown after the past step, or clicking in the sidebar `Messenger` -> `Settings`, scroll down to the section `Access Tokens`, click on `Add or Remove Pages`, this will take you to select the page you want to link with your app (select only one page) and grant all permissions solicited in the view.
- Scroll down in the same view to the section `Webhooks`, and click `Add Subscriptions`, in the modal, select the next three options: `messages`, `message_deliveries` and `message_reads` and click `Save`
- Log into your Mercately account, go to the sidebar `Integraciones` option, and click `Conectar con Messenger`, this will take you to the facebook views to connect your app with Mercately.
- You have to grant all permissions solicited in the modal shown, so your Facebook App could be properly managed (select only one page in the modals shown in this step). Your config should look like this:
![Your config should look like this](https://i.imgur.com/KPp7Z21.png)

#### Create ML test users
A real ML account has some limitations like:
- Your products can be bought
- You have a buy number limit
- You will need to use multiple emails to create them

To create some test users follow these steps:
- Get your own [Access Token](https://developers.mercadolibre.com.ec/en_us/authentication-and-authorization#token)
- Open your term and write:
```sh
curl -X POST -H "Content-Type: application/json" -d
'{
  "site_id": "MEC"
}'
https://api.mercadolibre.com/users/test_user?access_token=[Your access_token]
```
Response should be something like:
```json
{
  "id": 120506781,
  "nickname": "TEST0548",
  "password": "qatest328",
  "site_status": "active"
}
```

##### Considerations
When working with test users, you need to take into account the following considerations (more info [here](https://developers.mercadolibre.com.ec/en_us/start-testing)):

    You can create up to 10 test users with your mercadolibre account.
    Test users won’t be active for too long, but once they expire, you can create new ones.
    List under the “Others” category as much as possible.
    Never list under “gold” or “gold_premium” so it doesn’t get to our home page.
    Test users can only operate with test items: Test users can only buy, sell, and make questions on test items.
    Test users showing no activity (buy, ask, publish, etc.) during 60 days are immediately removed.
    Test items are removed regularly.
