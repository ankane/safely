# Safely

:fire: Awesome exception handling

```ruby
safely do
  # keep going if this code fails
end
```

Exceptions are rescued and automatically reported to your favorite reporting service.

In development and test environments, exceptions are raised so you can fix them. :smirk:

## Use It Everywhere

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
show_banner = safely(default: true) { show_banner_logic }
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

Reports exceptions to a variety of services out of the box thanks to [Errbase](https://github.com/ankane/errbase).

- [Rollbar](https://rollbar.com/)
- [Airbrake](https://airbrake.io/)
- [Exceptional](http://www.exceptional.io/)
- [Honeybadger](https://www.honeybadger.io/)
- [Sentry](https://getsentry.com/)
- [Raygun](https://raygun.io/)
- [Bugsnag](https://bugsnag.com/)
- [Appsignal](https://appsignal.com/)
- [Opbeat](https://opbeat.com/)

Customize reporting with:

```ruby
Safely.report_exception_method = proc { |e| Rollbar.error(e) }
```

By default, exception messages are prefixed with `[safely]`. This makes it easier to spot rescued exceptions. Turn this off with:

```ruby
Safely.tag = false
```

To report exceptions manually:

```ruby
Safely.report_exception(e)
```

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'safely_block'
```

## History

View the [changelog](https://github.com/ankane/safely/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/safely/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/safely/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
