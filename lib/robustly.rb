require "robustly/version"
require "errbase"

module Robustly
  class << self
    attr_accessor :env, :tag, :report_exception_method

    def report_exception(e)
      report_exception_method.call(e)
    end
  end

  DEFAULT_EXCEPTION_METHOD = proc do |e|
    e = e.dup # leave original exception unmodified
    e.message.prepend("[safely] ") if e.message && Robustly.tag
    Errbase.report(e)
  end

  self.env = ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
  self.tag = true
  self.report_exception_method = DEFAULT_EXCEPTION_METHOD

  module Methods
    def safely(options = {})
      yield
    rescue *Array(options[:only] || StandardError) => e
      raise e if Array(options[:except]).any? { |c| e.is_a?(c) }
      raise e if %w(development test).include?(Robustly.env)
      sample = options[:sample] || options[:throttle]
      if sample ? rand < 1.0 / sample : true
        begin
          Robustly.report_exception(e) unless Array(options[:silence]).any? { |c| e.is_a?(c) }
        rescue => e2
          $stderr.puts "FAIL-SAFE #{e2.class.name}: #{e2.message}"
        end
      end
      options[:default]
    end
    alias_method :yolo, :safely
    alias_method :robustly, :safely # legacy
  end
end

Object.send :include, Robustly::Methods
