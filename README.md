# Robustly

Unexpected data can cause errors in production - don’t let it bring down the system

```ruby
safely do
  # keep going if this code fails
end
```

Exceptions are rescued and reported to your favorite reporting service.

In development and test environments, exceptions are raised so you can fix them. :smirk:

## Examples

Great for analytics

```ruby
safely { track_event("Search") }
```

and background jobs

```ruby
User.find_each do |user|
  safely { cache_recommendations(user) }
end
```

Also aliased as `yolo`.

## Features

Throttle reporting with:

```ruby
safely sample: 1000 do
  # reports ~ 1/1000 errors
end
```

Specify a default value to return on exceptions

```ruby
score = safely(default: 30) { calculate_score }
```

Raise specific exceptions

```ruby
safely except: ActiveRecord::RecordNotUnique do
  # all other exceptions will be rescued
end
```

Pass an array for multiple exception classes.

Rescue only specific exceptions

```ruby
safely only: ActiveRecord::RecordNotUnique do
  # all other exceptions will be raised
end
```

Silence exceptions

```ruby
safely(silence: ActiveRecord::RecordNotUnique) { code }
```

## Reporting

Reports exceptions to [Rollbar](https://rollbar.com/), [Airbrake](https://airbrake.io/), [Exceptional](http://www.exceptional.io/), [Honeybadger](https://www.honeybadger.io/), [Sentry](https://getsentry.com/), [Raygun](https://raygun.io/), and [Bugsnag](https://bugsnag.com/) out of the box thanks to [Errbase](https://github.com/ankane/errbase).

Customize reporting with:

```ruby
Robustly.report_exception_method = proc { |e| Rollbar.error(e) }
```

By default, exception messages are prefixed with `[safely]`. This makes it easier to spot rescued exceptions. Turn this off with:

```ruby
Robustly.tag = false
```

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'robustly'
```

## History

View the [changelog](https://github.com/ankane/robustly/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/robustly/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/robustly/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
