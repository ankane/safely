module Safely
  DEFAULT_EXCEPTION_METHOD = proc do |e, info|
    begin
      if defined?(Airbrake)
        Airbrake.notify(e, info)
      end

      if defined?(Appsignal)
        Appsignal.send_error(e) do |transaction|
          transaction.set_tags(info)
        end
      end

      if defined?(Bugsnag)
        Bugsnag.notify(e) do |report|
          report.add_tab(:info, info) if info.any?
        end
      end

      if defined?(Datadog::Tracing)
        Datadog::Tracing.active_span&.set_tags(info)
        Datadog::Tracing.active_span&.set_error(e)
      end

      if defined?(ExceptionNotifier)
        ExceptionNotifier.notify_exception(e, data: info)
      end

      if defined?(Google::Cloud::ErrorReporting)
        # TODO add info
        Google::Cloud::ErrorReporting.report(e)
      end

      if defined?(Honeybadger)
        Honeybadger.notify(e, context: info)
      end

      if defined?(NewRelic::Agent)
        NewRelic::Agent.notice_error(e, custom_params: info)
      end

      if defined?(Raygun)
        Raygun.track_exception(e, custom_data: info)
      end

      if defined?(Rollbar)
        Rollbar.error(e, info)
      end

      if defined?(ScoutApm::Error)
        # no way to add context for a single call
        # ScoutApm::Context.add(info)
        ScoutApm::Error.capture(e)
      end

      if defined?(Sentry)
        Sentry.capture_exception(e, extra: info)
      end
    rescue => e
      $stderr.puts "[safely] Error reporting exception: #{e.class.name}: #{e.message}"
    end
  end
end
