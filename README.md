# Magicbell::Rails

Wrapper around magicbell api to deliver notifications to your users in a background job

## Usage

How to use my plugin.

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

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
