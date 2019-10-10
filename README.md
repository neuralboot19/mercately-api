# Mercately  
[![Maintainability](https://api.codeclimate.com/v1/badges/439ed5a23d7af6e1d4da/maintainability)](https://codeclimate.com/repos/5d94b45a3bf77409dc002e04/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/439ed5a23d7af6e1d4da/test_coverage)](https://codeclimate.com/repos/5d94b45a3bf77409dc002e04/test_coverage)

## Setting up the environment

Our environment:
* Ruby 2.5.3
* Rails 5.2.2
* PostgreSQL 11.1

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

