# Robustly

Don’t let small errors bring down the system

```ruby
robustly do
  # keep going if this code fails
end
```

Raises exceptions in development and test environments and rescues and reports exceptions elsewhere.

Also aliased as `yolo`.

```ruby
yolo do
  # get crazy in here
end
```

Reports exceptions to [Rollbar](https://rollbar.com/), [Airbrake](https://airbrake.io/), [Exceptional](http://www.exceptional.io/), [Honeybadger](https://www.honeybadger.io/), [Sentry](https://getsentry.com/), [Raygun](https://raygun.io/), and [Bugsnag](https://bugsnag.com/) out of the box thanks to [Errbase](https://github.com/ankane/errbase).

Customize reporting with:

```ruby
Robustly.report_exception_method = proc {|e| Rollbar.report_exception(e) }
```

And throttle reporting with:

```ruby
robustly throttle: 1000 do
  # reports ~ 1/1000 errors
end
```

Specify a default value to return on errors [master]:

```ruby
robustly default: 30 do
  # big bucks, no whammy
end
```

Catch specific errors

```ruby
robustly only: [ActiveRecord::RecordNotUnique] do
  # all other exceptions will be raised
end
```

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'robustly'
```

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/robustly/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/robustly/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
