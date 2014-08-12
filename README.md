# Robustly

Don’t let small errors bring down the system

```ruby
robustly do
  # keep going if this code fails
end
```

Raises exceptions in development and test environments and rescues and reports exceptions elsewhere.

Also aliased to `yolo`.

```ruby
yolo do
  # you only live once
end
```

Reports exceptions to [Rollbar](https://rollbar.com/), [Honeybadger](https://www.honeybadger.io/), [Airbrake](https://airbrake.io/), [Exceptional](http://www.exceptional.io/), [Exception Notification](http://smartinez87.github.io/exception_notification/), and [Raygun](https://raygun.io/) out of the box thanks to [Errbase](https://github.com/ankane/errbase).

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

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'robustly'
```

## TODO

- ability to catch specific errors

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/robustly/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/robustly/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
