[![Build Status](https://travis-ci.org/ankane/safely.svg?branch=master)](https://travis-ci.org/ankane/safely)

# Safely

Safely is an implementation of the [Safely pattern](https://ankane.org/safely-pattern) for Ruby. This is a way of dealing with exceptions safely (!) while keeping your code DRY. Raise exceptions while you're working but protect your end-users from seeing them, without rewriting your code.

Safely wraps your code in a block like this to protect your users from exceptions:

```ruby
safely do
  # keep going if this code fails
end
```

When your code is wrapped like this, exceptions will be rescued and optionally reported to your favorite reporting service when running on your live environment. In development and test environments, however, exceptions are still raised so you can fix them.

[Read more](https://ankane.org/safely-pattern)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'safely_block'
```

## Use It Everywhere

Safely is best if you use it everywhere your code might raise an exception.

“Oh no, analytics brought down search”

```ruby
safely { track_search(params) }
```

“Recommendations stopped updating because of one bad user”

```ruby
users.each do |user|
  safely { update_recommendations(user) }
end
```

`safely` is also aliased as `yolo`.

## Configuration

Pass extra context to be reported with exceptions:

```ruby
safely context: {user_id: 123} do
  # code
end
```

Specify a default value to return on exceptions:

```ruby
show_banner = safely(default: true) { show_banner_logic }
```

Suppress specific exceptions by passing their name (or names in an array):

```ruby
safely except: ActiveRecord::RecordNotUnique do
  # all other exceptions will be rescued
end
```

Rescue only specific exceptions by passing their name (or names in an array):

```ruby
safely only: ActiveRecord::RecordNotUnique do
  # all other exceptions will be raised
end
```

Silence exceptions by passing their name (or names in an array):

```ruby
safely silence: ActiveRecord::RecordNotUnique do
  # code
end
```

Throttle reporting:

```ruby
safely throttle: {limit: 10, period: 1.minute} do
  # reports only first 10 exceptions each minute
end
```

**Note:** The throttle limit is approximate and per process.

## Reporting

Safely-block allows you to report exceptions to a variety of services out of the box thanks to [Errbase](https://github.com/ankane/errbase).

- [Airbrake](https://airbrake.io/)
- [Appsignal](https://appsignal.com/)
- [Bugsnag](https://bugsnag.com/)
- [Exception Notification](https://github.com/smartinez87/exception_notification)
- [Google Stackdriver](https://cloud.google.com/stackdriver/)
- [Honeybadger](https://www.honeybadger.io/)
- [Opbeat](https://opbeat.com/)
- [Raygun](https://raygun.io/)
- [Rollbar](https://rollbar.com/)
- [Sentry](https://getsentry.com/)

Customize reporting by adding a configuration line to an initializer (`config/initializers/safely.rb`):

```ruby
# frozen_string_literal: true

Rails.application.configure do
  Safely.report_exception_method = ->(e) { Rollbar.error(e) } if ENV['RAILS_ENV'] == 'production'
end
```

By default, exception messages are prefixed with `[safely]`. This makes it easier to spot rescued exceptions. Turn this off in your initializer with:

```ruby
Safely.tag = false
```

To report exceptions manually, use this method in your code:

```ruby
Safely.report_exception(e)
```

## Data Protection

To protect the privacy of your users, do not send [personal data](https://en.wikipedia.org/wiki/Personally_identifiable_information) to exception services. Filter sensitive form fields, use ids (not email addresses) to identify users, and mask IP addresses.

With Rollbar, you can do:

```ruby
Rollbar.configure do |config|
  config.person_id_method = "id" # default
  config.scrub_fields |= [:birthday]
  config.anonymize_user_ip = true
end
```

While working on exceptions, be on the lookout for personal data and correct as needed.

## History

View the [changelog](https://github.com/ankane/safely/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/safely/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/safely/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development and testing:

```sh
git clone https://github.com/ankane/safely.git
cd safely
bundle install
rake test
```
