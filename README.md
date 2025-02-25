[![CircleCI](https://dl.circleci.com/status-badge/img/gh/NEXL-LTS/magicbell-rails/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/NEXL-LTS/magicbell-rails/tree/main)

# Magicbell::Rails

Wrapper around magicbell api to:
- deliver notifications to your users in a background job
- fetch categories
- update notification preferences

## Installation

Add this line to your application's Gemfile:

```ruby
gem "magicbell-rails"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install magicbell-rails
```

## Usage

set environment variables

```bash
$ export MAGICBELL_API_KEY=your_api_key
$ export MAGICBELL_API_SECRET=your_api_secret
```

```ruby
Magicbell::Rails.bell(
  title: 'Welcome to MagicBell',
  topic: 'welcome',
  recipients: [
    {
      first_name: 'Joe',
      last_name: 'Bob',
      email: 'jj@example.io',
      phone_numbers: ['+61431000000'],
      external_id: '123',
      custom_attributes: {
        age: 30
      }
    }
  ],
  content: 'The notification inbox for your product. Get started in minutes.',
  category: 'new_message',
  action_url: 'https://magicbell.com/docs',
  custom_attributes: {
    order: {
      id: '1202983',
      title: 'A title you can use in your templates'
    }
  }
).deliver_later
```

```ruby
# Gets all categories that have been created
Magicbell::Rails.fetch_categories(external_id:)
```

```ruby
# Updates notification preferences given a payload
payload = { 'notification_preferences' => {
              'categories' => [
                { 'slug' => 'stay_in_touch', 'channels' => [{ 'slug' => 'email', 'enabled' => false }] },
                { 'slug' => 'list_shared', 'channels' => [{ 'slug' => 'email', 'enabled' => false }] }
              ]
            }
          }.to_json
Magicbell::Rails.update_notification_preferences(external_id:, payload:)
```

```ruby
# Returns true if the users exists
Magicbell::Rails.user_exists?(external_id:)
```

```ruby
# Creates a user
Magicbell::Rails.create_user(external_id:, email:, first_name:, last_name:, phone_numbers:)
```

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
