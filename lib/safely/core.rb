require "safely/version"
require "errbase"
require "digest"

module Safely
  class << self
    attr_accessor :raise_envs, :tag, :report_exception_method, :throttle_counter
    attr_writer :env

    def report_exception(e)
      report_exception_method.call(e)
    end

    def env
      @env ||= ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
    end

    def throttled?(e, options)
      return false unless options
      key = "#{options[:key] || Digest::MD5.hexdigest([e.class.name, e.message, e.backtrace.join("\n")].join("/"))}/#{(Time.now.to_i / options[:period]) * options[:period]}"
      throttle_counter.clear if throttle_counter.size > 1000 # prevent from growing indefinitely
      (throttle_counter[key] += 1) > options[:limit]
    end
  end

  DEFAULT_EXCEPTION_METHOD = proc do |e|
    e = e.dup # leave original exception unmodified
    e.message.prepend("[safely] ") if e.message && Safely.tag
    Errbase.report(e)
  end

  self.tag = true
  self.report_exception_method = DEFAULT_EXCEPTION_METHOD
  self.raise_envs = %w(development test)
  # not thread-safe, but we don't need to be exact
  self.throttle_counter = Hash.new(0)

  module Methods
    def safely(options = {})
      yield
    rescue *Array(options[:only] || StandardError) => e
      raise e if Array(options[:except]).any? { |c| e.is_a?(c) }
      raise e if Safely.raise_envs.include?(Safely.env)
      sample = options[:sample]
      if sample ? rand < 1.0 / sample : true
        begin
          Safely.report_exception(e) unless Array(options[:silence]).any? { |c| e.is_a?(c) } || Safely.throttled?(e, options[:throttle])
        rescue => e2
          $stderr.puts "FAIL-SAFE #{e2.class.name}: #{e2.message}"
        end
      end
      options[:default]
    end
    alias_method :yolo, :safely
  end
  extend Methods
end
